import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:fuel_and_fix/user/screens/uber.dart';
import 'package:url_launcher/url_launcher.dart';

/// Helper function that uses the Haversine formula to calculate the distance (in kilometers)
/// between two geographic coordinates.
double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const double p =
      0.017453292519943295; // pi / 180 (to convert degrees to radians)
  final double a = 0.5 -
      cos((lat2 - lat1) * p) / 2 +
      cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a)); // 2 * 6371 km (Earth's radius)
}

class TowingServiceCategories extends StatefulWidget {
  @override
  _TowingServiceCategoriesState createState() =>
      _TowingServiceCategoriesState();
}

class _TowingServiceCategoriesState extends State<TowingServiceCategories> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _currentWorkshop;
  String enteredLocation = ''; // Variable to store search text
  String _selectedSituation =
      ''; // Variable to store selected vehicle situation

  @override
  void initState() {
    super.initState();
  }

  /// Fetches the current user's location from Firestore (from the "user" collection)
  /// and then retrieves all workshops from the "tow" collection. For each workshop, we
  /// calculate the distance (using the Haversine formula) from the user's location, add that
  /// as a new field, and then sort the list (shortest distance first).
  Future<List<Map<String, dynamic>>> _getWorkshops() async {
    // Get current user
    User? user = FirebaseAuth.instance.currentUser;
    double userLat = 0.0;
    double userLon = 0.0;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('user').doc(user.uid).get();
      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userLat = userData["additionalData"]['latitude'] ?? 0.0;
      userLon = userData["additionalData"]['longitude'] ?? 0.0;
    }

    QuerySnapshot querySnapshot = await _firestore
        .collection('tow')
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
    // Sort workshops by distance (ascending: shortest first)
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

  // Filter workshops based on entered location text (case-insensitive).
  List<Map<String, dynamic>> getFilteredWorkshops(
      List<Map<String, dynamic>> workshops) {
    if (enteredLocation.isEmpty) {
      return workshops;
    }
    return workshops
        .where((workshop) =>
            workshop['additionalData']?['location_name']
                ?.toLowerCase()
                .contains(enteredLocation.toLowerCase()) ??
            false)
        .toList();
  }

  /// Stores the confirmed tow request in Firestore under the
  /// 'request' subcollection of the corresponding workshop in the 'tow' collection.
  /// The new request is stored with status false (pending) and isPaid set to false.
  Future<void> _confirmRequest(Map<String, dynamic> workshop) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(user.uid).get();
    String userLocation =
        userDoc['additionalData']['location_name'] ?? 'Unknown Location';

    await _firestore
        .collection('tow')
        .doc(workshop['id'])
        .collection('request')
        .add({
      'status': false, // Request pending acceptance
      'isPaid': false, // Advance not paid yet
      'read': false, // Pending request; not accepted/rejected yet.

      'timestamp': FieldValue.serverTimestamp(),
      'userId': user.uid,
      'userLocation': userLocation,
      'vehicleSituation': _selectedSituation,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request Sent!")),
    );
  }

  /// Displays a confirmation dialog before sending a request.
  void _showConfirmationDialog(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside.
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Request'),
          content: Text('Are you sure you want to send this request?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel the action.
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _confirmRequest(workshop);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a payment dialog to simulate paying the advance.
  /// In a real scenario, you would integrate a payment gateway.
  void _showPaymentDialogForTow(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Pay Advance'),
          content: Text('Do you want to pay the advance for this tow service?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  /// Queries for the existing tow request for the current user in the given workshop,
  /// and if found with status true and isPaid false, updates that document to set isPaid to true.
  Future<void> _updateTowPaymentStatus(String workshopId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    QuerySnapshot querySnapshot = await _firestore
        .collection('tow')
        .doc(workshopId)
        .collection('request')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: true)
        .where('isPaid', isEqualTo: false)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference requestDoc = querySnapshot.docs.first.reference;
      await requestDoc.update({
        'isPaid': true,
        'timestamp': FieldValue.serverTimestamp(), // Update timestamp if needed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Advance Payment Successful!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No accepted request found to update.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 105, 66, 125),
        title: Text(
          'Available Tow Services',
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
            // Search TextField
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
            // Dropdown for vehicle situation
            DropdownButton<String>(
              value: _selectedSituation.isEmpty ? null : _selectedSituation,
              hint: Text('Select Vehicle Situation'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedSituation = newValue!;
                });
              },
              items: <String>[
                'Other',
                'Vehicle Stuck',
                'Accident Recovery',
                'Vehicle Breakdown',
                'Accident',
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            // Display workshops
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
                  final filteredWorkshops = getFilteredWorkshops(workshops);

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
                                      // Main Card Content
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Color.fromARGB(255, 118, 72, 141),
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
                                              // Action Buttons (Send Request, Feedback)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _showConfirmationDialog(
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
                                                            service: 'tow',
                                                            userId: FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    ?.uid ??
                                                                '',
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
                                              // StreamBuilder to check for an accepted but unpaid request
                                              StreamBuilder<QuerySnapshot>(
                                                stream: _firestore
                                                    .collection('tow')
                                                    .doc(workshop['id'])
                                                    .collection('request')
                                                    .where('userId',
                                                        isEqualTo: FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid)
                                                    .snapshots(),
                                                builder: (context, snapshot) {
                                                  if (!snapshot.hasData ||
                                                      snapshot
                                                          .data!.docs.isEmpty) {
                                                    return Container();
                                                  }
                                                  var requestDoc =
                                                      snapshot.data!.docs.first;
                                                  var requestData = requestDoc
                                                          .data()
                                                      as Map<String, dynamic>;
                                                  if (requestData['status'] ==
                                                          true &&
                                                      requestData['isPaid'] ==
                                                          false) {}
                                                  return Container();
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // Uber Section Button Positioned at the Top Right
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(
                                                255, 204, 225, 109),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    UberSection(),
                                              ),
                                            );
                                          },
                                          icon: Icon(
                                            Icons.directions_car,
                                            size: 18,
                                          ),
                                          label: Text('Uber'),
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
    );
  }
}
