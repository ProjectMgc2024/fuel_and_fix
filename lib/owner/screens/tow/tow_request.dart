import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:url_launcher/url_launcher.dart';

class TowRequest extends StatefulWidget {
  @override
  _TowRequestState createState() => _TowRequestState();
}

class _TowRequestState extends State<TowRequest> {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  // Local map to store the response status for each request.
  Map<String, bool> _statusResult = {};

  // Function to fetch the company name
  Future<String> fetchCompanyName() async {
    try {
      DocumentSnapshot companyDoc = await FirebaseFirestore.instance
          .collection('tow')
          .doc(currentUserId)
          .get();

      if (companyDoc.exists) {
        return companyDoc['companyName'] ?? 'N/A';
      }
    } catch (e) {
      print('Error fetching company name: $e');
    }
    return 'N/A';
  }

  // Function to update request status
  Future<void> updateRequestStatus(
      String requestId, bool newStatus, String userId) async {
    try {
      // Fetch company name
      String companyName = await fetchCompanyName();

      // Update the request status and mark it as responded
      await FirebaseFirestore.instance
          .collection('tow')
          .doc(currentUserId)
          .collection('request')
          .doc(requestId)
          .update({'status': newStatus, 'responded': true});

      // Add a notification for the requesting user
      await FirebaseFirestore.instance.collection('notifications').add({
        'userId': userId,
        'companyId': currentUserId,
        'companyName': companyName,
        'status': newStatus ? 'Accepted' : 'Rejected',
        'message': newStatus
            ? '$companyName accepted your request.'
            : '$companyName rejected your request.',
        'timestamp': FieldValue.serverTimestamp(),
        'read':
            false, // <-- New field added to mark the notification as unread.
      });

      // Update local state so UI shows the updated response
      setState(() {
        _statusResult[requestId] = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated and notification sent.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  // Function to fetch user details
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

  // Function to open Google Maps
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

  // Function to format timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('MMM dd, yyyy, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tow Requests'),
        backgroundColor: const Color.fromARGB(255, 123, 173, 168),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tow')
            .doc(currentUserId)
            .collection('request')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No requests found.'));
          }

          final requests = snapshot.data!.docs;

          return FutureBuilder<String>(
            future: fetchCompanyName(),
            builder: (context, companySnapshot) {
              if (companySnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              String companyName = companySnapshot.data ?? 'N/A';

              return ListView.builder(
                itemCount: requests.length,
                itemBuilder: (context, index) {
                  var request = requests[index].data() as Map<String, dynamic>;
                  String requestId = requests[index].id;

                  return FutureBuilder<Map<String, dynamic>?>(
                    future: fetchUserDetails(request['userId']),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!userSnapshot.hasData || userSnapshot.data == null) {
                        return ListTile(
                          title: Text(companyName),
                          subtitle: Text('Error fetching user details'),
                        );
                      }

                      var userDetails = userSnapshot.data!;
                      var additionalData = userDetails['additionalData'] ?? {};
                      double latitude = additionalData['latitude'] ?? 0.0;
                      double longitude = additionalData['longitude'] ?? 0.0;
                      String locationName =
                          additionalData['location_name'] ?? 'Unknown Location';
                      String vehicleSituation =
                          request['vehicleSituation'] ?? 'N/A';
                      Timestamp timestamp =
                          request['timestamp'] ?? Timestamp.now();
                      String formattedTimestamp = formatTimestamp(timestamp);

                      // Check if the request has already been responded to
                      bool respondedFromFirestore =
                          request.containsKey('responded') &&
                              request['responded'] == true;
                      bool responded = respondedFromFirestore ||
                          _statusResult.containsKey(requestId);
                      bool accepted;
                      if (respondedFromFirestore) {
                        accepted = request['status'];
                      } else if (_statusResult.containsKey(requestId)) {
                        accepted = _statusResult[requestId]!;
                      } else {
                        accepted = false;
                      }

                      return Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // User Image
                              Center(
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundImage: NetworkImage(
                                      userDetails['userImage'] ?? ''),
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
                              Text('Company: $companyName'),
                              Text('Email: ${userDetails['email'] ?? 'N/A'}'),
                              Text('Phone: ${userDetails['phoneno'] ?? 'N/A'}'),
                              Text(
                                  'License: ${userDetails['license'] ?? 'N/A'}'),
                              Text(
                                  'Vehicle Type: ${userDetails['vehicleType'] ?? 'N/A'}'),
                              Text(
                                  'Registration No: ${userDetails['registrationNo'] ?? 'N/A'}'),
                              Text('Location: $locationName'),
                              Text('Vehicle Situation: $vehicleSituation'),
                              Text('Timestamp: $formattedTimestamp'),
                              SizedBox(height: 16),
                              // If not responded, show buttons; otherwise, display status text.
                              if (!responded)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        updateRequestStatus(
                                            requestId, true, request['userId']);
                                      },
                                      child: Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        updateRequestStatus(requestId, false,
                                            request['userId']);
                                      },
                                      child: Text('Reject'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.location_on,
                                          color: Colors.blue),
                                      onPressed: () {
                                        openGoogleMaps(latitude, longitude);
                                      },
                                    ),
                                  ],
                                )
                              else
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    accepted
                                        ? 'Request Accepted'
                                        : 'Request Rejected',
                                    style: TextStyle(
                                      color:
                                          accepted ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
          );
        },
      ),
    );
  }
}
