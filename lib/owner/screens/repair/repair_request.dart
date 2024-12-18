import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmergencyRepairRequest extends StatefulWidget {
  @override
  _EmergencyRepairRequestsPageState createState() =>
      _EmergencyRepairRequestsPageState();
}

class _EmergencyRepairRequestsPageState extends State<EmergencyRepairRequest> {
  List<Map<String, dynamic>> requests = [];

  // Fetch requests from Firestore and user details
  Future<void> fetchRequests() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) {
      return;
    }

    try {
      // Fetch requests where workshopId matches the current user's UID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('request')
          .where('workshopId', isEqualTo: userUid)
          .get();

      List<Map<String, dynamic>> tempRequests = [];

      for (var doc in querySnapshot.docs) {
        final request = {
          'companyName': doc['companyName'] ?? 'Unknown',
          'description': doc['description'] ?? 'N/A',
          'timestamp': doc['timestamp']?.toDate().toString() ?? 'N/A',
          'userId': doc['userId'] ?? 'Unknown',
          'workshopId': doc['workshopId'] ?? 'Unknown',
          'docId': doc.id, // Document ID for updating status
        };

        // Fetch user details from the user collection
        final userSnapshot = await FirebaseFirestore.instance
            .collection('user')
            .doc(request['userId'])
            .get();

        if (userSnapshot.exists) {
          request.addAll({
            'email': userSnapshot['email'] ?? 'N/A',
            'license': userSnapshot['license'] ?? 'N/A',
            'phoneno': userSnapshot['phoneno'] ?? 'N/A',
            'registrationNo': userSnapshot['registrationNo'] ?? 'N/A',
            'userImage': userSnapshot['userImage'] ??
                'https://via.placeholder.com/150', // Default image
            'username': userSnapshot['username'] ?? 'N/A',
            'vehicleType': userSnapshot['vehicleType'] ?? 'N/A',
          });
        }

        tempRequests.add(request);
      }

      setState(() {
        requests = tempRequests;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load requests: $e')),
      );
    }
  }

  // Update the request's status in Firestore
  Future<void> updateRequestStatus(String docId, bool status) async {
    try {
      await FirebaseFirestore.instance
          .collection('request')
          .doc(docId)
          .update({'status': status});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request ${status ? 'accepted' : 'rejected'}')),
      );

      // Refresh the list
      fetchRequests();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update request: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRequests(); // Fetch the requests when the widget is initialized
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Repair Requests'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                if (requests.isEmpty)
                  Center(child: Text('No requests found for this workshop.'))
                else
                  for (int index = 0; index < requests.length; index++)
                    Card(
                      elevation: 6,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Company name
                            Text(
                              'Company: ${requests[index]['companyName']}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Description: ${requests[index]['description']}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Requested At: ${requests[index]['timestamp']}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                            SizedBox(height: 10),

                            // User details
                            Text(
                              'User Details:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 8),
                            Text('Username: ${requests[index]['username']}'),
                            Text('Email: ${requests[index]['email']}'),
                            Text('Phone: ${requests[index]['phoneno']}'),
                            Text('Location: ${requests[index]['location']}'),
                            Text(
                                'Vehicle Type: ${requests[index]['vehicleType']}'),
                            Text(
                                'Registration No: ${requests[index]['registrationNo']}'),
                            SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                requests[index]['userImage'],
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  onPressed: () => updateRequestStatus(
                                      requests[index]['docId'], true),
                                  child: Text('Accept'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => updateRequestStatus(
                                      requests[index]['docId'], false),
                                  child: Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
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
        ),
      ),
    );
  }
}
