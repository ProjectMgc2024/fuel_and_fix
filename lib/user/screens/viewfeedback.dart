import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ViewFeedbackPage extends StatefulWidget {
  @override
  _ViewFeedbackPageState createState() => _ViewFeedbackPageState();
}

class _ViewFeedbackPageState extends State<ViewFeedbackPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _user;
  bool _isLoading = true;
  Map<String, Map<String, String?>> _companyDetails =
      {}; // Map to store company details (company name and owner) by service

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  // Get the current user
  Future<void> _getCurrentUser() async {
    _user = _auth.currentUser;
    if (_user != null) {
      // After getting the user, fetch the feedback data
      setState(() {
        _isLoading = false;
      });
    } else {
      // Handle case when the user is not authenticated
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fetch feedback data for the current user
  Future<QuerySnapshot> _getFeedbackData() async {
    return _firestore
        .collection('feedback')
        .where('userId', isEqualTo: _user!.uid)
        .get();
  }

  // Fetch the company details (company name and owner) from the dynamically referenced collection
  Future<void> _getCompanyDetails(String service, String ownerId) async {
    if (_companyDetails.containsKey(service)) {
      return; // If the company details for the service are already fetched, do nothing
    }

    try {
      // Use the service value to dynamically reference the collection, and fetch the document using ownerId as the document ID
      DocumentSnapshot companyDoc = await _firestore
          .collection(service) // Use service field as collection name
          .doc(
              ownerId) // Use ownerId from feedback to fetch the correct document
          .get();

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
            'companyName': 'No company name found',
            'ownerName': 'No owner found'
          };
        });
      }
    } catch (e) {
      print('Error fetching company details: $e');
      setState(() {
        _companyDetails[service] = {
          'companyName': 'Error fetching company name',
          'ownerName': 'Error fetching owner'
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Collection'),
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
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No feedback found.'));
                }

                // Data found for the current user
                final feedbackDocs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: feedbackDocs.length,
                  itemBuilder: (context, index) {
                    var feedbackData = feedbackDocs[index];
                    var service = feedbackData['service'] ?? 'defaultService';
                    var ownerId = feedbackData['ownerId'] ?? '';

                    // Fetch company details based on service value and ownerId
                    _getCompanyDetails(service, ownerId);

                    return ListTile(
                      title: Text('Feedback for service: $service'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(feedbackData['feedback'] ?? 'No Message'),
                          SizedBox(height: 8),
                          FutureBuilder(
                            future: _getCompanyDetails(service, ownerId),
                            builder: (context, companySnapshot) {
                              if (_companyDetails.containsKey(service)) {
                                var companyDetails = _companyDetails[service];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Company: ${companyDetails?['companyName']}'),
                                    Text(
                                        'Owner: ${companyDetails?['ownerName']}'),
                                  ],
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
