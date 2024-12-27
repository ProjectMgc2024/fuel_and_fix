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
  Map<String, Map<String, String?>> _companyDetails = {};

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

  Future<void> _getCompanyDetails(String service, String ownerId) async {
    if (_companyDetails.containsKey(service)) {
      return;
    }

    try {
      DocumentSnapshot companyDoc =
          await _firestore.collection(service).doc(ownerId).get();

      if (companyDoc.exists) {
        setState(() {
          _companyDetails[service] = {
            'companyName': companyDoc['companyName'],
            'ownerName': companyDoc['ownerName']
          };
        });
      } else {
        setState(() {
          _companyDetails[service] = {
            'companyName': 'Unknown Company',
            'ownerName': 'Unknown Owner'
          };
        });
      }
    } catch (e) {
      setState(() {
        _companyDetails[service] = {
          'companyName': 'Error fetching company',
          'ownerName': 'Error fetching owner'
        };
      });
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();
    // Format the DateTime into the desired format
    return DateFormat('d MMMM yyyy at HH:mm:ss z').format(dateTime);
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

                    _getCompanyDetails(service, ownerId);

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
                              style: TextStyle(fontSize: 14),
                            ),
                            SizedBox(height: 12),
                            if (timestamp != null)
                              Text(
                                'Submitted on: ${_formatTimestamp(timestamp)}',
                                style: TextStyle(
                                    fontSize: 13,
                                    color:
                                        const Color.fromARGB(255, 46, 6, 95)),
                              ),
                            SizedBox(height: 12),
                            FutureBuilder(
                              future: _getCompanyDetails(service, ownerId),
                              builder: (context, _) {
                                if (_companyDetails.containsKey(service)) {
                                  var companyDetails = _companyDetails[service];
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.business,
                                              color: Colors.green),
                                          SizedBox(width: 8),
                                          Text(
                                            'Company: ${companyDetails?['companyName']}',
                                            style: TextStyle(fontSize: 16),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.person,
                                              color: const Color.fromARGB(
                                                  255, 74, 65, 50)),
                                          SizedBox(width: 8),
                                          Text(
                                            'Owner: ${companyDetails?['ownerName']}',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                }
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
