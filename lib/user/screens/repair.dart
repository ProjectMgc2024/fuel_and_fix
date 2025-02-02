import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// Calculates the great-circle distance (in kilometers) between two points
/// using the Haversine formula.
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p = 0.017453292519943295; // pi/180: convert degrees to radians
  final double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 2 * Earth's radius (≈6371 km)
}

class WorkshopScreen extends StatefulWidget {
  @override
  _WorkshopScreenState createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;
  Map<String, dynamic>? _currentWorkshop;
  String? _currentLocationName;
  bool _isUpdatingLocation =
      false; // To show a loading indicator while updating location
  String enteredLocation = ''; // For search filtering

  // Vehicle problems and their checkbox states
  // (If needed for repair requests, you can add similar functionality here)
  // For now, we keep the code as-is.

  TextEditingController _vehicleSituationController = TextEditingController();

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
    _vehicleSituationController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  /// Fetches workshops from the 'repair' collection. In addition,
  /// it retrieves the current user's location from Firestore (from the 'user' collection),
  /// computes the distance of each workshop from the user, attaches a 'distance' field,
  /// and sorts the list (shortest first).
  Future<List<Map<String, dynamic>>> _getWorkshops() async {
    // Retrieve current user location from the 'user' collection.
    User? user = FirebaseAuth.instance.currentUser;
    double userLat = 0.0;
    double userLon = 0.0;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('user').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userLat = userData["additionalData"]['latitude'] ?? 0.0;
      userLon = userData["additionalData"]['longitude'] ?? 0.0;
      _currentLocationName =
          userData["additionalData"]['location_name'] ?? 'Unknown Location';
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection('repair')
        .where('status', isEqualTo: true)
        .where('isApproved', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> workshops = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      double workshopLat = 0.0;
      double workshopLon = 0.0;
      if (data.containsKey('additionalData')) {
        Map<String, dynamic> addData = data['additionalData'];
        workshopLat = addData['latitude'] is double
            ? addData['latitude']
            : double.tryParse(addData['latitude'].toString()) ?? 0.0;
        workshopLon = addData['longitude'] is double
            ? addData['longitude']
            : double.tryParse(addData['longitude'].toString()) ?? 0.0;
      }
      double distance =
          calculateDistance(userLat, userLon, workshopLat, workshopLon);
      workshops.add({
        'id': doc.id,
        ...data,
        'distance': distance,
      });
    }
    // Sort workshops by ascending distance (closest first)
    workshops.sort((a, b) => a['distance'].compareTo(b['distance']));
    return workshops;
  }

  // Function to launch the phone dialer.
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch phone number';
    }
  }

  // Filter workshops based on the entered location.
  List<Map<String, dynamic>> getFilteredWorkshops(
      List<Map<String, dynamic>> workshops) {
    if (enteredLocation.isEmpty) {
      return workshops;
    }
    return workshops.where((workshop) {
      final loc =
          workshop['additionalData']?['location_name']?.toLowerCase() ?? '';
      return loc.contains(enteredLocation.toLowerCase());
    }).toList();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentWorkshop == null) return;
    // Get user's location from Firestore.
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(user.uid).get();
    String userLocation =
        userDoc['additionalData']['location_name'] ?? 'Unknown Location';

    // Prepare the repair request data.
    Map<String, dynamic> requestData = {
      'isPayment': true,
      'paymentId': response.paymentId,
      'status': true,
      'timestamp': DateTime.now(),
      'userId': user.uid,
      'userLocation': userLocation,
      'vehicleSituation': _vehicleSituationController.text,
      // Add any additional fields (e.g., vehicle problems) as required.
    };

    try {
      await _firestore
          .collection('repair')
          .doc(_currentWorkshop!['id'])
          .collection('request')
          .add(requestData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment and request submitted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $error')),
      );
    }

    setState(() {
      _currentWorkshop = null;
    });
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

  void _payWithRazorpay(Map<String, dynamic> workshop) {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': 50000, // Amount in paise (500.00 INR)
      'name': 'Repair Service',
      'description': 'Repair service payment',
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

  // Dialog to input vehicle situation and (optionally) additional details.
  // This is used before initiating the payment.
  void _showLocationAndPaymentDialog(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside.
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Enter Vehicle Situation'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _vehicleSituationController,
                      decoration: InputDecoration(
                        labelText: 'Describe the situation',
                        hintText: 'e.g., engine trouble, brake issues, etc.',
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: () {
                        _payWithRazorpay(workshop);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.payments),
                      label: Text('Pay Advance'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredWorkshops = getFilteredWorkshops([]);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 78, 104),
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
                    enteredLocation = text; // Update search text.
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
                  fillColor: Colors.white,
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
                  final filteredWorkshops = enteredLocation.isEmpty
                      ? workshops
                      : workshops.where((workshop) {
                          final loc = workshop['additionalData']
                                      ?['location_name']
                                  ?.toLowerCase() ??
                              '';
                          return loc.contains(enteredLocation.toLowerCase());
                        }).toList();

                  return filteredWorkshops.isEmpty
                      ? Center(
                          child: Text(
                              'No workshops found for the entered location.'))
                      : Expanded(
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
                                              Color.fromARGB(255, 33, 93, 128),
                                              Color.fromARGB(255, 116, 29, 29)
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
                                                            color:
                                                                Color.fromARGB(
                                                                    255,
                                                                    244,
                                                                    172,
                                                                    113),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      122,
                                                                      118,
                                                                      207),
                                                              size: 18,
                                                            ),
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
                                                            GestureDetector(
                                                              onTap: () {
                                                                _launchPhone(workshop[
                                                                        'phoneNo'] ??
                                                                    'Not Available');
                                                              },
                                                              child: Icon(
                                                                Icons.phone,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        58,
                                                                        202,
                                                                        56),
                                                                size: 18,
                                                              ),
                                                            ),
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
                                                              Icons.car_repair,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
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
                                                        SizedBox(height: 8),
                                                        // Display calculated distance.
                                                        Text(
                                                          "Distance: ${workshop['distance'].toStringAsFixed(2)} km",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .white70),
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
                                                        color: Color.fromARGB(
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
                                                            service: 'repair',
                                                            userId: FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.feedback,
                                                        color: Color.fromARGB(
                                                            255, 83, 56, 46)),
                                                    label: Text('Feedback'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Optionally add additional buttons (e.g., Uber) here.
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
    );
  }
}
