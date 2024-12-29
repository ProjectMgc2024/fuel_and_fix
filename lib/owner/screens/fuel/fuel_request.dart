import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class FuelFillingRequest extends StatefulWidget {
  @override
  _FuelFillingRequestState createState() => _FuelFillingRequestState();
}

class _FuelFillingRequestState extends State<FuelFillingRequest> {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  Future<void> updateRequestStatus(String requestId, bool newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('fuel')
          .doc(currentUserId)
          .collection('request')
          .doc(requestId)
          .update({'status': newStatus});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated successfully.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchUserDetails(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('user').doc(userId).get();
      return userDoc.data() as Map<String, dynamic>?;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  Future<void> openGoogleMaps(double latitude, double longitude) async {
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open Google Maps.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Requests'),
        backgroundColor: const Color.fromARGB(255, 123, 173, 168),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('fuel')
            .doc(currentUserId)
            .collection('request')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No requests found.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              var request = requests[index].data() as Map<String, dynamic>;
              String requestId = requests[index].id;

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchUserDetails(request['userId']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!userSnapshot.hasData || userSnapshot.data == null) {
                    return ListTile(
                      title: Text(request['companyName'] ?? 'No Company Name'),
                      subtitle: Text('Error fetching user details'),
                    );
                  }

                  var userDetails = userSnapshot.data!;
                  var additionalData = userDetails['additionalData'] ?? {};
                  double latitude = additionalData['latitude'] ?? 0.0;
                  double longitude = additionalData['longitude'] ?? 0.0;
                  String locationName =
                      additionalData['location_name'] ?? 'Unknown Location';

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Image
                          Center(
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  NetworkImage(userDetails['userImage'] ?? ''),
                              onBackgroundImageError: (_, __) =>
                                  Icon(Icons.person, size: 40),
                            ),
                          ),
                          SizedBox(height: 16),

                          // User Details
                          Text(
                            userDetails['username'] ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('Email: ${userDetails['email'] ?? 'N/A'}'),
                          Text('Phone: ${userDetails['phoneno'] ?? 'N/A'}'),
                          Text('License: ${userDetails['license'] ?? 'N/A'}'),
                          Text(
                              'Vehicle Type: ${userDetails['vehicleType'] ?? 'N/A'}'),
                          Text(
                              'Registration No: ${userDetails['registrationNo'] ?? 'N/A'}'),
                          Text('Location: $locationName'),

                          SizedBox(height: 16),

                          // Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  updateRequestStatus(requestId, true);
                                },
                                child: Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  updateRequestStatus(requestId, false);
                                },
                                child: Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                              ),
                              IconButton(
                                icon:
                                    Icon(Icons.location_on, color: Colors.blue),
                                onPressed: () {
                                  openGoogleMaps(latitude, longitude);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
