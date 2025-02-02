import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewFeedbackPage extends StatefulWidget {
  @override
  _ViewFeedbackPageState createState() => _ViewFeedbackPageState();
}

class _ViewFeedbackPageState extends State<ViewFeedbackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    _user = _auth.currentUser;
    setState(() {
      _isLoading = false;
    });
  }

  Future<QuerySnapshot> _getFeedbackData() async {
    return _firestore
        .collection('feedback')
        .where('userId', isEqualTo: _user!.uid)
        .get();
  }

  Future<Map<String, String>> _getCompanyDetails(
      String service, String ownerId) async {
    try {
      DocumentSnapshot companyDoc =
          await _firestore.collection(service).doc(ownerId).get();

      if (companyDoc.exists) {
        return {
          'companyName': companyDoc['companyName'] ?? 'Unknown Company',
          'ownerName': companyDoc['ownerName'] ?? 'Unknown Owner',
        };
      } else {
        return {
          'companyName': 'Unknown Company',
          'ownerName': 'Unknown Owner',
        };
      }
    } catch (e) {
      return {
        'companyName': 'Error fetching company',
        'ownerName': 'Error fetching owner',
      };
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Collection'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 170, 130, 61),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder<QuerySnapshot>(
              future: _getFeedbackData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No feedback found.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  );
                }

                final feedbackDocs = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: feedbackDocs.length,
                  itemBuilder: (context, index) {
                    var feedbackData = feedbackDocs[index];
                    var service = feedbackData['service'] ?? 'defaultService';
                    var ownerId = feedbackData['ownerId'] ?? '';
                    var timestamp = feedbackData['timestamp'] as Timestamp?;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.feedback,
                                    color: const Color.fromARGB(
                                        255, 152, 122, 47)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Feedback for $service',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Text(
                              feedbackData['feedback'] ??
                                  'No feedback provided.',
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 12),
                            if (timestamp != null)
                              Text(
                                'Submitted on: ${_formatTimestamp(timestamp)}',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color.fromARGB(255, 46, 6, 95)),
                              ),
                            SizedBox(height: 15),

                            // Use FutureBuilder to fetch company details
                            FutureBuilder<Map<String, String>>(
                              future: _getCompanyDetails(service, ownerId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(
                                      child: CircularProgressIndicator());
                                }
                                if (snapshot.hasError) {
                                  return Text('Error loading company details',
                                      style: TextStyle(color: Colors.red));
                                }
                                var companyDetails = snapshot.data ??
                                    {
                                      'companyName': 'Unknown Company',
                                      'ownerName': 'Unknown Owner',
                                    };

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.business,
                                            color: Colors.green),
                                        SizedBox(width: 8),
                                        Text(
                                          'Company: ${companyDetails['companyName']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.person,
                                            color: Color.fromARGB(
                                                255, 70, 114, 123)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Owner: ${companyDetails['ownerName']}',
                                          style: TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
