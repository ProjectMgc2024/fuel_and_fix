import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Calculates the great-circle distance between two points (in kilometers)
/// using the Haversine formula.
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p = 0.017453292519943295; // pi/180
  final double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 2 * Earth's radius (≈6371 km)
}

class FuelStationList extends StatefulWidget {
  @override
  _FuelStationListState createState() => _FuelStationListState();
}

class _FuelStationListState extends State<FuelStationList> {
  List<Map<String, dynamic>> fuelStations = [];
  String enteredLocation = '';
  String? currentUserId;
  // These will be updated by fetchCurrentLocation(), but here we also fetch from Firestore user doc.
  double? _latitude;
  double? _longitude;
  String? _locationName;
  Map<String, double> fuelPrices = {};

  StreamSubscription? _priceSubscription;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
    fetchCurrentLocation();
    fetchFuelStations();

    // Listen for changes in fuel prices so that updates made by admin are reflected automatically.
    _priceSubscription = FirebaseFirestore.instance
        .collection('price')
        .doc('fuelPrices')
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists && mounted) {
        setState(() {
          fuelPrices = {
            'diesel': docSnapshot.data()?['diesel']?.toDouble() ?? 0.0,
            'petrol': docSnapshot.data()?['petrol']?.toDouble() ?? 0.0,
          };
        });
      }
    });
  }

  @override
  void dispose() {
    _priceSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchCurrentUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (mounted) {
        setState(() {
          currentUserId = user?.uid;
        });
      }
    } catch (e) {
      print('Error fetching current user ID: $e');
    }
  }

  /// Fetch the current location using geolocator and update Firestore user doc.
  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Location services are disabled. Please enable them to proceed.')),
        );
      }
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Location permissions are permanently denied. Please update your settings.')),
        );
      }
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      Placemark place = placemarks.first;

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = '${place.locality}, ${place.country}';
      });

      if (currentUserId != null) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(currentUserId)
            .update({
          'additionalData': {
            'latitude': _latitude,
            'longitude': _longitude,
            'location_name': _locationName,
          },
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  /// Fetches fuel stations from the "fuel" collection and computes their distance
  /// from the user's current location (from Firestore user doc).
  Future<void> fetchFuelStations() async {
    try {
      if (currentUserId == null) {
        await fetchCurrentUserId();
      }
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUserId)
          .get();
      Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>? ?? {};
      double userLat = userData["additionalData"]?['latitude'] ?? 0.0;
      double userLon = userData["additionalData"]?['longitude'] ?? 0.0;

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('fuel')
          .where('isApproved', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> tempStations = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['companyName'] ?? 'Unknown Station',
          'location': data['additionalData']?['location_name'] ?? '',
          'latitude': data['additionalData']?['latitude'] ?? 0.0,
          'longitude': data['additionalData']?['longitude'] ?? 0.0,
          'address': data['email'] ?? '',
          'contactNumber': data['phoneNo'] ?? '',
          'fuels': List<String>.from(
              data['fuels']?.map((fuel) => fuel['type'] ?? '') ?? []),
          'service': data['service'] ?? '',
        };
      }).toList();

      for (var station in tempStations) {
        double stationLat = station['latitude'] is double
            ? station['latitude']
            : double.tryParse(station['latitude'].toString()) ?? 0.0;
        double stationLon = station['longitude'] is double
            ? station['longitude']
            : double.tryParse(station['longitude'].toString()) ?? 0.0;
        double distance =
            calculateDistance(userLat, userLon, stationLat, stationLon);
        station['distance'] = distance;
      }

      tempStations.sort((a, b) => a['distance'].compareTo(b['distance']));

      if (!mounted) return;
      setState(() {
        fuelStations = tempStations;
      });

      // You can also call fetchFuelPrices() here if needed, but the snapshot listener will update fuelPrices.
    } catch (e) {
      print('Error fetching fuel stations: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredStations() {
    if (enteredLocation.isEmpty) {
      return fuelStations;
    }
    return fuelStations.where((station) {
      final loc = station['location']?.toLowerCase() ?? '';
      return loc.contains(enteredLocation.toLowerCase());
    }).toList();
  }

  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch phone number';
    }
  }

  Future<void> _openGoogleMaps(
      {required double latitude, required double longitude}) async {
    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch Google Maps";
    }
  }

  /// Displays a dialog to enter the quantity (in liters) for a selected fuel.
  Future<void> showFuelPurchaseDialog(
      Map<String, dynamic> station, String fuelType, double price) async {
    await showDialog(
      context: context,
      builder: (context) {
        double enteredQuantity = 0.0;
        return StatefulBuilder(
          builder: (context, setState) {
            double paymentAmount = enteredQuantity * price;
            bool isValid = enteredQuantity > 0 && enteredQuantity <= 10;
            return AlertDialog(
              title: Text("Buy $fuelType"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Enter quantity in liters (max 10L):"),
                  SizedBox(height: 10),
                  TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      double? qty = double.tryParse(value);
                      setState(() {
                        enteredQuantity = qty ?? 0.0;
                      });
                    },
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Quantity (L)",
                    ),
                  ),
                  SizedBox(height: 10),
                  Text("Total: ₹${paymentAmount.toStringAsFixed(2)}"),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: isValid
                      ? () {
                          Navigator.of(context).pop();
                          _sendFuelRequest(station, fuelType, enteredQuantity,
                              paymentAmount);
                        }
                      : null,
                  child: Text("Send Request"),
                )
              ],
            );
          },
        );
      },
    );
  }

  /// Sends the fuel purchase request to Firestore (in the "request" subcollection
  /// of the fuel station document) without any payment processing.
  Future<void> _sendFuelRequest(Map<String, dynamic> station, String fuelType,
      double quantity, double paymentAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> requestData = {
      'fuelType': fuelType,
      'litres': quantity,
      'paymentAmount': paymentAmount,
      'isPaid': false, // Payment not made yet
      'status': false, // Initial status (e.g. pending)
      'read': false, // New field added
      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
    };

    try {
      await FirebaseFirestore.instance
          .collection('fuel')
          .doc(station['id'])
          .collection('request')
          .add(requestData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fuel request sent successfully!')),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send request: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStations = getFilteredStations();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Stations',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 149, 96, 39),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 238, 238, 238),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25), topRight: Radius.circular(25)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    enteredLocation = text;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search for a location',
                  prefixIcon: Icon(Icons.search, color: Colors.blue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            if (filteredStations.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Text(
                  'No fuel stations found for the entered location.',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStations.length,
                itemBuilder: (context, index) {
                  final station = filteredStations[index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 35, 41, 55),
                            Color.fromARGB(255, 149, 96, 39),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                station['name'],
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.place, color: Colors.orangeAccent),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    station['location'],
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.white),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _openGoogleMaps(
                                      latitude: double.parse(
                                          station['latitude'].toString()),
                                      longitude: double.parse(
                                          station['longitude'].toString()),
                                    );
                                  },
                                  icon: Icon(Icons.location_on,
                                      color: Color.fromARGB(255, 66, 128, 175)),
                                ),
                              ],
                            ),
                            Divider(height: 20, color: Colors.white60),
                            Row(
                              children: [
                                Icon(
                                  Icons.email,
                                  color: Color.fromARGB(255, 217, 227, 217),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Email: ${station['address']}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white70),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _launchPhone(station['contactNumber'] ??
                                        'Not Available');
                                  },
                                  child: Row(
                                    children: [
                                      Icon(Icons.phone,
                                          color:
                                              Color.fromARGB(255, 58, 202, 56),
                                          size: 18),
                                      SizedBox(width: 8),
                                      Text(
                                        'Contact: ${station['contactNumber']}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 15),
                              ],
                            ),
                            Wrap(
                              spacing: 10,
                              children:
                                  station['fuels'].map<Widget>((fuelType) {
                                double price =
                                    fuelPrices[fuelType.toLowerCase()] ?? 0.0;
                                return ActionChip(
                                  backgroundColor:
                                      Color.fromARGB(255, 170, 123, 30),
                                  label: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(fuelType,
                                          style:
                                              TextStyle(color: Colors.white)),
                                      SizedBox(width: 5),
                                      Text(
                                        '₹${price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  onPressed: () {
                                    showFuelPurchaseDialog(
                                        station, fuelType, price);
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 15),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FeedbackScreen(
                                        stationId: station['id'],
                                        stationName: station['name'],
                                        service: 'fuel',
                                        userId: currentUserId,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 120, 135, 67),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 30.0, vertical: 12.0),
                                ),
                                child: Text(
                                  'Give Feedback',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Center(
                              child: Text(
                                "Distance: ${station['distance'].toStringAsFixed(2)} km",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
