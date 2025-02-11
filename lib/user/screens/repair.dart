import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
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
  Map<String, dynamic>? _currentWorkshop;
  String? _currentLocationName;
  bool _isUpdatingLocation =
      false; // To show a loading indicator while updating location
  String enteredLocation = ''; // For search filtering

  TextEditingController _vehicleSituationController = TextEditingController();

  // Temporary variables to store workshop info for which payment is being made.
  Map<String, dynamic>? _currentWorkshopForPayment;
  String? _currentWorkshopIdForPayment;

  @override
  void dispose() {
    _vehicleSituationController.dispose();
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

  // Submits the repair request by storing it in Firestore.
  Future<void> _submitRequest(Map<String, dynamic> workshop) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    DocumentSnapshot userDoc =
        await _firestore.collection('user').doc(user.uid).get();
    String userLocation =
        userDoc['additionalData']['location_name'] ?? 'Unknown Location';

    // Prepare the repair request data.
    Map<String, dynamic> requestData = {
      'status':
          false, // Initially pending; later service provider will set to true.
      'isPaid': false, // Advance not paid yet.
      'timestamp': DateTime.now(),
      'userId': user.uid,
      'userLocation': userLocation,
      'vehicleSituation': _vehicleSituationController.text,
    };

    try {
      await _firestore
          .collection('repair')
          .doc(workshop['id'])
          .collection('request')
          .add(requestData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request submitted successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit request: $error')),
      );
    }
  }

  // Dialog to input vehicle situation and submit the request.
  void _showRequestDialog(Map<String, dynamic> workshop) {
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
                        hintText: 'e.g., brake issues, engine trouble, etc.',
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
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
                    await _submitRequest(workshop);
                  },
                  child: Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
            // Search TextField.
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
                                                        _showRequestDialog(
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
                                              // StreamBuilder to check for an accepted but unpaid repair request.
                                              StreamBuilder<QuerySnapshot>(
                                                stream: _firestore
                                                    .collection('repair')
                                                    .doc(workshop['id'])
                                                    .collection('request')
                                                    .where('userId',
                                                        isEqualTo: FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            ?.uid)
                                                    .snapshots(),
                                                builder:
                                                    (context, requestSnapshot) {
                                                  if (!requestSnapshot
                                                          .hasData ||
                                                      requestSnapshot
                                                          .data!.docs.isEmpty) {
                                                    return Container();
                                                  }
                                                  var requestDoc =
                                                      requestSnapshot
                                                          .data!.docs.first;
                                                  var requestData = requestDoc
                                                          .data()
                                                      as Map<String, dynamic>;
                                                  if (requestData['status'] ==
                                                          true &&
                                                      requestData['isPaid'] ==
                                                          false) {
                                                    return Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          (
                                                            workshop,
                                                            workshop['id']
                                                          );
                                                        },
                                                        child:
                                                            Text("Pay Advance"),
                                                      ),
                                                    );
                                                  } else if (requestData[
                                                              'status'] ==
                                                          true &&
                                                      requestData['isPaid'] ==
                                                          true) {
                                                    return Align(
                                                      alignment:
                                                          Alignment.centerRight,
                                                    );
                                                  }
                                                  return Container();
                                                },
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
    );
  }
}
