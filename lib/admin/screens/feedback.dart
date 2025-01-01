import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class adminfeedback extends StatefulWidget {
  @override
  _adminfeedbackState createState() => _adminfeedbackState();
}

class _adminfeedbackState extends State<adminfeedback> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // List to hold the feedback data categorized by service type
  Map<String, List<Map<String, dynamic>>> categorizedFeedback = {
    'fuel': [],
    'repair': [],
    'tow': [],
  };

  // Fetch username from user collection
  Future<String> _getUsername(String userId) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('user').doc(userId).get();
    if (userSnapshot.exists && userSnapshot['username'] != null) {
      return userSnapshot['username'];
    } else {
      return 'Unknown User';
    }
  }

  // Fetch company name based on service and ownerId
  Future<String> _getCompanyName(String service, String ownerId) async {
    CollectionReference serviceCollection;

    if (service == 'fuel') {
      serviceCollection = _firestore.collection('fuel');
    } else if (service == 'repair') {
      serviceCollection = _firestore.collection('repair');
    } else if (service == 'tow') {
      serviceCollection = _firestore.collection('tow');
    } else {
      return 'Unknown Company';
    }

    DocumentSnapshot serviceSnapshot =
        await serviceCollection.doc(ownerId).get();
    if (serviceSnapshot.exists && serviceSnapshot['companyName'] != null) {
      return serviceSnapshot['companyName'];
    } else {
      return 'Unknown Company';
    }
  }

  // Fetch all feedback from Firestore and categorize by service type
  Future<void> _fetchFeedback() async {
    QuerySnapshot snapshot = await _firestore
        .collection('feedback')
        .orderBy('timestamp') // Sort feedback by timestamp
        .get();

    Map<String, List<Map<String, dynamic>>> categorizedFeedbackLocal = {
      'fuel': [],
      'repair': [],
      'tow': [],
    };

    for (var doc in snapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      String service = data['service'] ?? ''; // Ensure service is not null
      if (categorizedFeedbackLocal.containsKey(service)) {
        categorizedFeedbackLocal[service]!.add({'data': data, 'id': doc.id});
      }
    }

    setState(() {
      categorizedFeedback =
          categorizedFeedbackLocal; // Update the state with categorized feedback
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

  // Build the UI for each feedback item
  Widget _buildFeedbackCard(Map<String, dynamic> feedback) {
    var feedbackData = feedback['data'];
    String feedbackId = feedback['id'];

    return FutureBuilder<String>(
      future: _getCompanyName(
          feedbackData['service'] ?? '', feedbackData['ownerId'] ?? ''),
      builder: (context, companyNameSnapshot) {
        if (companyNameSnapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (companyNameSnapshot.hasError) {
          return Text('Error: ${companyNameSnapshot.error}');
        } else if (companyNameSnapshot.hasData) {
          String companyName = companyNameSnapshot.data ?? 'Unknown Company';

          return FutureBuilder<String>(
            future: _getUsername(feedbackData['userId'] ?? ''),
            builder: (context, usernameSnapshot) {
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return CircularProgressIndicator();
              } else if (usernameSnapshot.hasError) {
                return Text('Error: ${usernameSnapshot.error}');
              } else if (usernameSnapshot.hasData) {
                String username = usernameSnapshot.data ?? 'Unknown User';

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feedback: ${feedbackData['feedback'] ?? 'No feedback'}',
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Company: $companyName',
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.black54),
                        ),
                        Text(
                          'Username: $username',
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.black54),
                        ),
                        Text(
                          'Timestamp: ${feedbackData['timestamp']?.toDate().toString() ?? 'No timestamp available'}',
                          style:
                              TextStyle(fontSize: 14.0, color: Colors.black54),
                        ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
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
        backgroundColor: const Color.fromARGB(255, 149, 139, 87),
      ),
      body: categorizedFeedback.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching data
          : ListView(
              children: [
                if (categorizedFeedback['fuel']!.isNotEmpty)
                  _buildSection('Fuel', categorizedFeedback['fuel']!,
                      Icons.local_gas_station),
                if (categorizedFeedback['repair']!.isNotEmpty)
                  _buildSection(
                      'Repair', categorizedFeedback['repair']!, Icons.build),
                if (categorizedFeedback['tow']!.isNotEmpty)
                  _buildSection(
                      'Tow', categorizedFeedback['tow']!, Icons.car_repair),
              ],
            ),
    );
  }

  // Build each section for a specific service type with icon
  Widget _buildSection(String sectionTitle,
      List<Map<String, dynamic>> feedbackList, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.orange, size: 30),
              SizedBox(width: 8),
              Text(
                sectionTitle,
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
            ],
          ),
          SizedBox(height: 12),
          Column(
            children: feedbackList
                .map((feedback) => _buildFeedbackCard(feedback))
                .toList(),
          ),
          Divider(color: Colors.grey), // Add a divider after each section
        ],
      ),
    );
  }
}
