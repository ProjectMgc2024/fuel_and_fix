import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Details'),
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
                  return Center(child: Text('No feedback available.'));
                }

                final feedbackDocs = snapshot.data!.docs;
                final userFeedback = feedbackDocs
                    .where((doc) => doc['ownerId'] == currentUserId);

                if (userFeedback.isEmpty) {
                  return Center(child: Text('No feedback for this user.'));
                }

                return ListView(
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

                        return Card(
                          margin: EdgeInsets.all(10),
                          child: ListTile(
                            title: Text('Service: ${data['service']}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Feedback: ${data['feedback']}'),
                                Text(
                                    'Timestamp: ${data['timestamp'].toDate()}'),
                                Text('Username: $username'),
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
