import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding

class TowingServiceCategories extends StatefulWidget {
  @override
  _TowingServiceCategoriesState createState() =>
      _TowingServiceCategoriesState();
}

class _TowingServiceCategoriesState extends State<TowingServiceCategories> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;
  Map<String, dynamic>? _currentWorkshop;
  Position? _currentPosition;
  String? _currentLocationName;
  bool _isUpdatingLocation = false; // To show loading indicator
  String enteredLocation = ''; // Variable to store search text

  @override
  void initState() {
    super.initState();
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

  // Function to get workshops from Firebase
  Future<List<Map<String, dynamic>>> _getWorkshops() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('tow')
        .where('status', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> workshops = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      workshops.add({
        'id': doc.id,
        ...data,
      });
    }
    return workshops;
  }

  // Filter workshops based on entered location
  List<Map<String, dynamic>> getFilteredWorkshops(
      List<Map<String, dynamic>> workshops) {
    if (enteredLocation.isEmpty) {
      return workshops; // No filter applied if search text is empty
    }
    return workshops
        .where((workshop) =>
            workshop['additionalData']?['location_name']
                ?.toLowerCase()
                .contains(enteredLocation.toLowerCase()) ??
            false)
        .toList();
  }

  // Payment success handler
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentWorkshop == null) return;

    await _firestore
        .collection('tow')
        .doc(_currentWorkshop!['id'])
        .collection('request')
        .add({
      'userId': user.uid,
      'paymentId': response.paymentId,
      'status': true,
      'isPayment': true,
      'timestamp': DateTime.now(),
      'userLocation': _currentLocationName, // Store the location name
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful and Request Sent!")),
    );

    setState(() {
      _currentWorkshop = null;
    });
  }

  // Payment error handler
  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  // External wallet handler
  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  // Function to start the payment process
  void _payWithRazorpay(Map<String, dynamic> workshop) {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': 50000, // Amount in paise (500.00 INR)
      'name': 'Tow Service',
      'description': 'Tow service payment',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
    };

    try {
      _currentWorkshop = workshop;
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Function to get current location and location name
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isUpdatingLocation = true; // Start loading
    });

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });

    // Reverse geocode to get the location name
    List<Placemark> placemarks = await GeocodingPlatform.instance!
        .placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _currentLocationName =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current Location: $_currentLocationName')),
      );

      // Update user collection with current location
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore.collection('user').doc(user.uid).update({
          'additionalData.latitude': position.latitude,
          'additionalData.longitude': position.longitude,
          'additionalData.location_name': _currentLocationName,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location updated successfully!')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update location: $error')),
          );
        });
      }
    }

    setState(() {
      _isUpdatingLocation = false; // Stop loading
    });
  }

  // Show the dialog for current location and pay now
  void _showLocationAndPaymentDialog(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Action'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  _getCurrentLocation();
                  Navigator.pop(context);
                },
                icon: Icon(Icons.my_location),
                label: Text(_currentLocationName ??
                    'Fetch Current Location...'), // Show the current location name or loading text
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  _payWithRazorpay(workshop);
                  Navigator.pop(context);
                },
                icon: Icon(Icons.payments),
                label: Text('Pay Now'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 105, 66, 125),
        title: Text(
          'Available Workshops',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    enteredLocation = text; // Update the entered location
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search for a location',
                  prefixIcon: Icon(Icons.search,
                      color: const Color.fromARGB(255, 52, 121, 177)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getWorkshops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No active workshops available.'));
                } else {
                  List<Map<String, dynamic>> workshops = snapshot.data!;
                  final filteredWorkshops = getFilteredWorkshops(
                      workshops); // Filter workshops based on the search

                  return filteredWorkshops.isEmpty
                      ? Center(
                          child: Text(
                              'No workshops found for the entered location.'))
                      : Expanded(
                          // Added to ensure the list takes up available space
                          child: ListView.builder(
                            itemCount: filteredWorkshops.length,
                            itemBuilder: (context, index) {
                              var workshop = filteredWorkshops[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      Colors.deepPurple.withOpacity(0.2),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color.fromARGB(
                                                  255, 118, 72, 141),
                                              const Color.fromARGB(
                                                  255, 116, 29, 29)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.network(
                                                      workshop['companyLogo'],
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          workshop[
                                                              'companyName'],
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                244, 172, 113),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .location_on,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    122,
                                                                    118,
                                                                    207),
                                                                size: 18),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                workshop['additionalData']
                                                                        ?[
                                                                        'location_name'] ??
                                                                    'Not Available',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(Icons.phone,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    58,
                                                                    202,
                                                                    56),
                                                                size: 18),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              workshop[
                                                                      'phoneNo'] ??
                                                                  'Not Available',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                                Icons
                                                                    .car_repair,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    255),
                                                                size: 18),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              workshop[
                                                                      'service'] ??
                                                                  'Not Available',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _showLocationAndPaymentDialog(
                                                            workshop),
                                                    icon: Icon(Icons.send,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 150, 142, 67)),
                                                    label: Text('Send Request'),
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FeedbackScreen(
                                                            stationId:
                                                                workshop['id'],
                                                            stationName: workshop[
                                                                'companyName'],
                                                            service: 'tow',
                                                            userId: FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.feedback,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 83, 56, 46)),
                                                    label: Text('Feedback'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                }
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: _isUpdatingLocation
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                ),
              ),
            )
          : null,
    );
  }
}
