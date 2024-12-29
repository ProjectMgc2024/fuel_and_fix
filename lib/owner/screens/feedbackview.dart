import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class FeedbackScreen extends StatefulWidget {
  @override
  _FeedbackScreenState createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  void _getCurrentUserId() {
    final user = _auth.currentUser;
    setState(() {
      currentUserId = user?.uid;
    });
  }

  Future<String> _getUsername(String userId) async {
    try {
      final userDoc = await _firestore.collection('user').doc(userId).get();
      if (userDoc.exists) {
        return userDoc.data()?['username'] ?? 'Unknown';
      } else {
        return 'Unknown';
      }
    } catch (e) {
      return 'Error';
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Feedback',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(255, 162, 150, 87),
      ),
      body: currentUserId == null
          ? Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('feedback').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text('No feedback available.',
                          style: TextStyle(fontSize: 16, color: Colors.grey)));
                }

                final feedbackDocs = snapshot.data!.docs;
                final userFeedback = feedbackDocs
                    .where((doc) => doc['ownerId'] == currentUserId);

                if (userFeedback.isEmpty) {
                  return Center(
                      child: Text('No feedback for this user.',
                          style: TextStyle(fontSize: 16, color: Colors.grey)));
                }

                return ListView(
                  padding: EdgeInsets.all(10),
                  children: userFeedback.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return FutureBuilder<String>(
                      future: _getUsername(data['userId']),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }

                        final username = userSnapshot.data ?? 'Unknown';
                        final timestamp = _formatTimestamp(data['timestamp']);
                        final service =
                            data['service'] ?? 'No service specified';
                        final feedbackText =
                            data['feedback'] ?? 'No feedback provided';

                        return Card(
                          elevation: 5,
                          margin: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: const Color.fromARGB(
                                          255, 188, 173, 123),
                                      child: Text(
                                          username
                                              .substring(0, 1)
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white)),
                                    ),
                                    SizedBox(width: 10),
                                    Text(username,
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Divider(color: Colors.grey[300]),
                                SizedBox(height: 10),

                                // Service and Icon
                                Row(
                                  children: [
                                    Icon(Icons.car_repair,
                                        color: Colors.blueAccent, size: 20),
                                    SizedBox(width: 8),
                                    Text('Service: $service',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                  ],
                                ),
                                SizedBox(height: 8),

                                // Feedback Text and Icon
                                Row(
                                  children: [
                                    Icon(Icons.comment,
                                        color: Colors.green, size: 20),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Feedback: $feedbackText',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700])),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),

                                // Timestamp and Icon
                                Row(
                                  children: [
                                    Icon(Icons.access_time,
                                        color: Colors.grey, size: 20),
                                    SizedBox(width: 8),
                                    Text('Timestamp: $timestamp',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                SizedBox(height: 8),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                );
              },
            ),
    );
  }
}
