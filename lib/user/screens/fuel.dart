import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart'; // For reverse geocoding


class FuelStationList extends StatefulWidget {
  @override
  _FuelStationListState createState() => _FuelStationListState();
}

class _FuelStationListState extends State<FuelStationList> {
  List<Map<String, dynamic>> fuelStations = [];
  String enteredLocation = '';
  String? selectedFuel;
  double quantity = 0.0;
  double totalPrice = 0.0;
  String? currentUserId;
  late Razorpay _razorpay;
  String? oId;
  String? selectedService;
  Position? currentPosition;
  String? _locationName;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
    fetchFuelStations();
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

  Future<void> fetchFuelStations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('fuel').get();

      setState(() {
        fuelStations = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['companyName'] ?? 'Unknown Station',
            'location': doc['additionalData']['location_name'] ?? '',
            'latitude': doc['additionalData']['latitude'] ?? '',
            'longitude': doc['additionalData']['longitude'] ?? '',
            'address': doc['email'] ?? '',
            'contactNumber': doc['phoneNo'] ?? '',
            'fuels': Map.fromIterable(
              doc['fuels'] ?? [],
              key: (fuel) => fuel['type'],
              value: (fuel) => fuel['price'],
            ),
            'service': doc['service'] ?? '',
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching fuel stations: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredStations() {
    if (enteredLocation.isEmpty) {
      return fuelStations;
    }
    return fuelStations
        .where((station) => station['location']!
            .toLowerCase()
            .contains(enteredLocation.toLowerCase()))
        .toList();
  }

  void calculatePrice(String fuel, double pricePerLiter, double qty) {
    setState(() {
      selectedFuel = fuel;
      quantity = qty;
      totalPrice = pricePerLiter * qty;
    });
  }

  Future<void> fetchCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    try {
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

      // Save location details
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

  Future<void> initiatePayment(String ownerId, String service) async {
    setState(() {
      oId = ownerId;
      selectedService = service;
    });

    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': (totalPrice * 100).toInt(),
      'name': 'Fuel & Fix',
      'description': 'Fuel purchase',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error initiating payment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment successful: ${response.paymentId}');
    await createRequest(response.paymentId!, true);
    await saveOrderDetails(response.paymentId!);
    _showSuccessDialog();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment failed: ${response.code} | ${response.message}');
    _showErrorDialog('Payment failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
  }

  Future<void> createRequest(String paymentId, bool isPayment) async {
    if (currentUserId == null) {
      print('User ID not available');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('fuel')
          .doc(oId)
          .collection('request')
          .add({
        'status': false,
        'timestamp': Timestamp.now(),
        'userId': currentUserId,
        'litres': quantity,
        'fuelType': selectedFuel,
        'paymentId': paymentId,
        'isPayment': isPayment,
      });
    } catch (e) {
      print('Error creating request: $e');
    }
  }

  Future<void> saveOrderDetails(String paymentId) async {
    if (currentUserId == null) {
      print('User ID not available');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(currentUserId)
          .collection('orders')
          .add({
        'ownerId': oId,
        'time': Timestamp.now(),
        'paymentAmount': totalPrice,
        'fuelType': selectedFuel,
        'litres': quantity,
        'paymentId': paymentId,
        'service': selectedService,
      });
    } catch (e) {
      print('Error saving order details: $e');
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

  void _showQuantityDialog(
      String fuelType, dynamic price, String ownerId, String service) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Quantity'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: 'Enter Quantity in Liters'),
                onChanged: (value) {
                  final qty = double.tryParse(value);
                  final pre = double.tryParse(price.toString());
                  if (qty != null && qty > 0) {
                    calculatePrice(fuelType, pre!, qty);
                  }
                },
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                icon: Icon(Icons.location_on),
                label: Text('Fetch Current Location'),
                onPressed: () async {
                  await fetchCurrentLocation();
                  Navigator.pop(context);
                  _showQuantityDialog(fuelType, price, ownerId, service);
                },
              ),
              if (_locationName != null) ...[
                SizedBox(height: 10),
                Text('Current Location: $_locationName',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                initiatePayment(ownerId, service);
              },
              child: Text('Proceed to Pay'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmation'),
        content: Text(
            'You ordered $quantity liters of $selectedFuel for ₹${totalPrice.toStringAsFixed(2)}. Request has been placed successfully.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

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
        backgroundColor: Color.fromARGB(
            255, 149, 96, 39), // Updated fuel color similar to cfuel
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
          color: Color.fromARGB(255, 238, 238, 238), // Light Gray Background
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
                  fillColor: Color.fromARGB(255, 255, 255, 255),
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
                      // Applying the gradient effect
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color.fromARGB(255, 35, 41, 55),
                            Color.fromARGB(255, 149, 96,
                                39), // Updated fuel color similar to cfuel
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
                                        fontSize: 16,
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    _openGoogleMaps(
                                      latitude: station['latitude'],
                                      longitude: station['longitude'],
                                    );
                                  },
                                  icon: Icon(Icons.location_on,
                                      color: const Color.fromARGB(
                                          255, 66, 128, 175)),
                                ),
                              ],
                            ),
                            Divider(height: 20, color: Colors.white60),
                            Text(
                              'Address: ${station['address']}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Contact: ${station['contactNumber']}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white70),
                            ),
                            SizedBox(height: 15),
                            Wrap(
                              spacing: 10,
                              children:
                                  station['fuels'].keys.map<Widget>((fuelType) {
                                final price = station['fuels'][fuelType];
                                return GestureDetector(
                                  onTap: () {
                                    _showQuantityDialog(fuelType, price,
                                        station['id'], station['service']);
                                  },
                                  child: Chip(
                                    label: Text(
                                        '$fuelType ₹${price.toStringAsFixed(2)}'),
                                    backgroundColor:
                                        const Color.fromARGB(255, 170, 123, 30),
                                    labelStyle: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255)),
                                  ),
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
                                  backgroundColor: const Color.fromARGB(
                                      255, 120, 135, 67), // Solid Green
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
