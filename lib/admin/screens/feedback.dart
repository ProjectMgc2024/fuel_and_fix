import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class adminfeedback extends StatefulWidget {
  @override
  _adminfeedbackState createState() => _adminfeedbackState();
}

class _adminfeedbackState extends State<adminfeedback> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to hold the feedback data
  Map<String, List<Map<String, dynamic>>> groupedFeedback = {
    'fuel': [],
    'repair': [],
    'tow': [],
  };

  // Fetch username from user collection
  Future<String> _getUsername(String userId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('user').doc(userId).get();
    if (userSnapshot.exists) {
      return userSnapshot['username'] ?? 'Unknown User';
    } else {
      return 'Unknown User';
    }
  }

  // Fetch company name based on service and ownerId
  Future<String> _getCompanyName(String service, String ownerId) async {
    CollectionReference serviceCollection;

    // Select the collection based on the service type
    if (service == 'fuel') {
      serviceCollection = _firestore.collection('fuel');
    } else if (service == 'repair') {
      serviceCollection = _firestore.collection('repair');
    } else if (service == 'tow') {
      serviceCollection = _firestore.collection('tow');
    } else {
      return 'Unknown Company'; // If service is not recognized
    }

    // Fetch company name using ownerId
    DocumentSnapshot serviceSnapshot =
        await serviceCollection.doc(ownerId).get();
    if (serviceSnapshot.exists) {
      return serviceSnapshot['companyName'] ?? 'Unknown Company';
    } else {
      return 'Unknown Company';
    }
  }

  // Fetch feedback from Firestore and group by service type
  Future<void> _fetchFeedback() async {
    QuerySnapshot snapshot = await _firestore
        .collection('feedback')
        .orderBy('timestamp') // Sort feedback by timestamp
        .get();

    Map<String, List<Map<String, dynamic>>> groupedFeedbackLocal = {
      'fuel': [],
      'repair': [],
      'tow': [],
    };

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String service = data['service'] ?? '';

      // Add feedback to the appropriate service category
      if (service == 'fuel') {
        groupedFeedbackLocal['fuel']?.add({'data': data, 'id': doc.id});
      } else if (service == 'repair') {
        groupedFeedbackLocal['repair']?.add({'data': data, 'id': doc.id});
      } else if (service == 'tow') {
        groupedFeedbackLocal['tow']?.add({'data': data, 'id': doc.id});
      }
    }

    setState(() {
      groupedFeedback =
          groupedFeedbackLocal; // Update the state with the new feedback
    });
  }

  // Delete the feedback from Firestore
  Future<void> _deleteFeedback(String documentId) async {
    if (documentId.isNotEmpty) {
      try {
        await _firestore.collection('feedback').doc(documentId).delete();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Feedback deleted successfully'),
        ));
        _fetchFeedback(); // Re-fetch the updated feedback after deletion
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error deleting feedback: $e'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Document ID is empty, cannot delete.'),
      ));
    }
  }

  // Build the UI for each section (fuel, repair, tow)
  Widget _buildFeedbackSection(
      String serviceName, List<Map<String, dynamic>> feedbackList) {
    if (feedbackList.isEmpty) return SizedBox();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            serviceName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Divider(),
          ...feedbackList.map((feedback) {
            var feedbackData = feedback['data']; // Access the data
            String feedbackId = feedback['id']; // Access the document ID

            return FutureBuilder<String>(
              future: _getCompanyName(
                  feedbackData['service'], feedbackData['ownerId']),
              builder: (context, companyNameSnapshot) {
                if (companyNameSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Show loading indicator until the company name is fetched
                } else if (companyNameSnapshot.hasError) {
                  return Text('Error: ${companyNameSnapshot.error}');
                } else if (companyNameSnapshot.hasData) {
                  String companyName =
                      companyNameSnapshot.data ?? 'Unknown Company';

                  return FutureBuilder<String>(
                    future: _getUsername(feedbackData['userId']),
                    builder: (context, usernameSnapshot) {
                      if (usernameSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Show loading indicator until the username is fetched
                      } else if (usernameSnapshot.hasError) {
                        return Text('Error: ${usernameSnapshot.error}');
                      } else if (usernameSnapshot.hasData) {
                        String username =
                            usernameSnapshot.data ?? 'Unknown User';

                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Feedback: ${feedbackData['feedback'] ?? 'No feedback'}',
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Company: $companyName', // Display companyName instead of ownerId
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Username: $username', // Display username
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                Text(
                                  'Timestamp: ${feedbackData['timestamp'].toDate().toString()}',
                                  style: TextStyle(fontSize: 14.0),
                                ),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // Ensure the feedbackId is passed correctly to the delete method
                                      _deleteFeedback(
                                          feedbackId); // Use the document ID for deletion
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return Text('No username available');
                      }
                    },
                  );
                } else {
                  return Text('No company name available');
                }
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchFeedback(); // Fetch feedback data when the screen is first loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Collection'),
      ),
      body: groupedFeedback.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching data
          : ListView(
              children: [
                _buildFeedbackSection('Fuel', groupedFeedback['fuel']!),
                _buildFeedbackSection('Repair', groupedFeedback['repair']!),
                _buildFeedbackSection('Tow', groupedFeedback['tow']!),
              ],
            ),
    );
  }
}
