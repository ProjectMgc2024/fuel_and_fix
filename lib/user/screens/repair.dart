import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:geolocator/geolocator.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart'; // Import geocoding package

class WorkshopScreen extends StatefulWidget {
  @override
  _WorkshopScreenState createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;
  String _locationName = "Use Current Location"; // Initial placeholder text

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

  Future<List<Map<String, dynamic>>> _getWorkshops() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('repair')
        .where('status', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> workshops = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      print('Document data: $data'); // Debug statement

      workshops.add({
        'id': doc.id,
        ...data,
      });
    }
    return workshops;
  }

  Future<void> _openGoogleMaps(
      {required double latitude, required double longitude}) async {
    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (await canLaunch(googleMapsUri.toString())) {
      await launch(googleMapsUri.toString());
    } else {
      throw "Could not launch Google Maps";
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('user').doc(user.uid).collection('orders').add({
      'ownerId': user.uid,
      'paymentAmount': 500,
      'paymentId': response.paymentId,
      'service': 'repair',
      'time': DateTime.now(),
      'description': 'Repair service payment',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful!")),
    );
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

  void _payWithRazorpay(String userId) {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': 250, // Amount in paise (500.00 INR)
      'name': 'Repair Service',
      'description': 'Repair service payment',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getLocationAndSendRequest() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Fetching location...'),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
        duration: Duration(minutes: 1),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.0),
        backgroundColor: Colors.deepPurple,
      ),
    );

    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location permission is denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location permission is permanently denied.')),
      );
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Use geocoding to get the place name from the coordinates
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    Placemark place = placemarks.first;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Store the location data in Firebase
    await _firestore.collection('user').doc(user.uid).set({
      'additionalData': {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'location_name':
            '${place.locality}, ${place.country}', // Dynamically fetched location
      },
    }, SetOptions(merge: true));

    // Fetch and update location name
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(user.uid).get();
    setState(() {
      _locationName = (userDoc.data() as Map<String, dynamic>)['additionalData']
              ['location_name'] ??
          "Use Current Location";
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location saved successfully!'),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(20.0),
        backgroundColor: Colors.deepPurple,
      ),
    );
  }

  void _showLocationMenu() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose an Option'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(_locationName),
                onTap: () {
                  Navigator.pop(context);
                  _getLocationAndSendRequest();
                },
              ),
              ListTile(
                title: Text('Pay Now'),
                onTap: () {
                  Navigator.pop(context);
                  _payWithRazorpay(
                      FirebaseAuth.instance.currentUser?.uid ?? '');
                },
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
        backgroundColor: const Color.fromARGB(255, 95, 73, 133),
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
            Navigator.pop(
                context); // This will pop the current screen from the stack and navigate back.
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
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

              return ListView.builder(
                itemCount: workshops.length,
                itemBuilder: (context, index) {
                  var workshop = workshops[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      shadowColor: Colors.deepPurple.withOpacity(0.2),
                      child: Stack(
                        children: [
                          // Card content (company details, etc.)
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color.fromARGB(255, 33, 93, 128)!,
                                  const Color.fromARGB(255, 116, 29, 29)!
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
                                  // Row for company logo and details
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
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
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              workshop['companyName'],
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 251, 159, 120),
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            // Location text placed back under company details
                                            Row(
                                              children: [
                                                Icon(Icons.location_on,
                                                    color: const Color.fromARGB(
                                                        255, 216, 214, 255),
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    // Access location_name from additionalData map
                                                    workshop['additionalData'] !=
                                                                null &&
                                                            workshop['additionalData']
                                                                    [
                                                                    'location_name'] !=
                                                                null
                                                        ? workshop[
                                                                'additionalData']
                                                            ['location_name']
                                                        : 'Not Available',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.phone,
                                                    color: Colors.white,
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text(
                                                  workshop['phoneNo'] ??
                                                      'Not Available',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(Icons.build,
                                                    color: Colors.white,
                                                    size: 18),
                                                SizedBox(width: 8),
                                                Text(
                                                  workshop['service'] ??
                                                      'Not Available',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.white,
                                                  ),
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
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Send Request Button
                                      Flexible(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            minimumSize:
                                                Size(0, 30), // Smaller size
                                          ),
                                          onPressed: _showLocationMenu,
                                          icon: Icon(Icons.send),
                                          label: Text('Send Request'),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      // Feedback Button
                                      Flexible(
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 6),
                                            minimumSize:
                                                Size(0, 30), // Smaller size
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FeedbackScreen(
                                                  stationId: workshop['id'],
                                                  stationName:
                                                      workshop['companyName'],
                                                  service: 'repair',
                                                  userId: FirebaseAuth.instance
                                                      .currentUser?.uid,
                                                ),
                                              ),
                                            );
                                          },
                                          icon: Icon(Icons.feedback),
                                          label: Text('Feedback'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Location Button positioned at top-right of the card
                          Positioned(
                            top: 8,
                            right: 8,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (workshop['additionalData']['latitude'] ==
                                        null ||
                                    workshop['additionalData']['longitude'] ==
                                        null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Location data is not available for this workshop.')),
                                  );
                                  return;
                                }
                                await _openGoogleMaps(
                                  latitude: workshop['additionalData']
                                      ['latitude'],
                                  longitude: workshop['additionalData']
                                      ['longitude'],
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                padding: EdgeInsets.all(8),
                                backgroundColor: Colors.white,
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
