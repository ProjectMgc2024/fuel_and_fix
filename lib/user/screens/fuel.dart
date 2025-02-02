import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  // These will be updated by fetchCurrentLocation(), but here we also
  // fetch from Firestore user doc.
  double? _latitude;
  double? _longitude;
  String? _locationName;
  Map<String, double> fuelPrices = {};

  late Razorpay _razorpay;
  // Holds details of the current fuel purchase for later use upon payment success.
  Map<String, dynamic>? _currentFuelPurchase;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
    // Also update the user's current location using geolocation.
    fetchCurrentLocation();
    // Then fetch the fuel stations; this function now uses the user's location from Firestore.
    fetchFuelStations();
    // Initialize Razorpay and set up event listeners.
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchCurrentUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        currentUserId = user?.uid;
      });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location services are disabled. Please enable them to proceed.')),
      );
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permissions are denied.')),
        );
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please update your settings.')),
      );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }

  /// Fetches fuel stations from the "fuel" collection and computes their distance
  /// from the user's current location (from Firestore user doc).
  Future<void> fetchFuelStations() async {
    try {
      // Ensure currentUserId is available.
      if (currentUserId == null) {
        await fetchCurrentUserId();
      }
      // Fetch the user document to get the current location.
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUserId)
          .get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      double userLat = userData["additionalData"]['latitude'] ?? 0.0;
      double userLon = userData["additionalData"]['longitude'] ?? 0.0;

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

      // Calculate distance for each fuel station.
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

      // Sort the stations by ascending order (shortest distance first).
      tempStations.sort((a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        fuelStations = tempStations;
      });

      await fetchFuelPrices();
    } catch (e) {
      print('Error fetching fuel stations: $e');
    }
  }

  Future<void> fetchFuelPrices() async {
    try {
      DocumentSnapshot priceDoc = await FirebaseFirestore.instance
          .collection('price')
          .doc('fuelPrices')
          .get();

      if (priceDoc.exists) {
        setState(() {
          fuelPrices = {
            'cng': priceDoc['cng']?.toDouble() ?? 0.0,
            'diesel': priceDoc['diesel']?.toDouble() ?? 0.0,
            'petrol': priceDoc['petrol']?.toDouble() ?? 0.0,
          };
        });
      }
    } catch (e) {
      print('Error fetching fuel prices: $e');
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
            double totalAmount = enteredQuantity * price;
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
                  Text("Total: ₹${totalAmount.toStringAsFixed(2)}"),
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
                          _payWithRazorpayForFuel(
                              station, fuelType, enteredQuantity, totalAmount);
                        }
                      : null,
                  child: Text(" Pay Advance"),
                )
              ],
            );
          },
        );
      },
    );
  }

  /// Initiates the Razorpay payment flow for a fuel purchase.
  void _payWithRazorpayForFuel(Map<String, dynamic> station, String fuelType,
      double quantity, double totalAmount) {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': (totalAmount * 100).toInt(), // Amount in paise.
      'name': station['name'],
      'description':
          'Purchase of ${quantity.toStringAsFixed(2)} L of $fuelType',
      'prefill': {
        'contact': station['contactNumber'] ?? '',
        'email': 'user@example.com',
      },
    };

    try {
      // Save current purchase details for use after payment.
      _currentFuelPurchase = {
        'station': station,
        'fuelType': fuelType,
        'quantity': quantity,
        'totalAmount': totalAmount,
      };
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Handles successful payment and records the fuel purchase in Firestore.
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _currentFuelPurchase != null) {
      DateTime timestamp = DateTime.now();
      Map<String, dynamic> requestData = {
        'fuelType': _currentFuelPurchase!['fuelType'],
        'isPayment': true,
        'litres': _currentFuelPurchase!['quantity'],
        'paymentId': response.paymentId,
        'status': false,
        'timestamp': timestamp,
        'userId': user.uid,
      };

      try {
        await FirebaseFirestore.instance
            .collection('fuel')
            .doc(_currentFuelPurchase!['station']['id'])
            .collection('request')
            .add(requestData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment and fuel request recorded successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to record request: $error')),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
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
                                  Icons.local_gas_station,
                                  color: Color.fromARGB(255, 217, 227, 217),
                                  size: 18,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Address: ${station['address']}',
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
                            // Display fuel chips as ActionChips (clickable)
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
