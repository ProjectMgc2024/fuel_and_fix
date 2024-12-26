import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ManageFeedbackPage extends StatefulWidget {
  @override
  _ManageFeedbackPageState createState() => _ManageFeedbackPageState();
}

class _ManageFeedbackPageState extends State<ManageFeedbackPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> feedbackList = [];

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  // Fetch feedback from Firestore
  Future<void> fetchFeedback() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('feedback').get();
      List<Map<String, dynamic>> feedback = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();

      setState(() {
        feedbackList = feedback;
      });
    } catch (e) {
      print('Error fetching feedback: $e');
    }
  }

  // Method to delete feedback based on document ID
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await _firestore.collection('feedback').doc(feedbackId).delete();
      setState(() {
        feedbackList.removeWhere((feedback) => feedback['id'] == feedbackId);
      });
      print('Feedback deleted successfully');
    } catch (e) {
      print('Error deleting feedback: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Manage Feedback and Complaints',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 85, 67, 116),
      ),
      body: feedbackList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: feedbackList.length,
              itemBuilder: (context, index) {
                var feedback = feedbackList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Vehicle: ${feedback['vehicleRegNo']}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 5),
                          Text(
                            'Rating: ${feedback['rating']}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          RatingBar.builder(
                            initialRating: feedback['rating'].toDouble(),
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 24,
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              // Handle rating change if needed
                            },
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteFeedback(feedback['id']),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FeedbackDetailPage(
                              feedbackId: feedback['id'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class FeedbackDetailPage extends StatelessWidget {
  final String feedbackId;

  FeedbackDetailPage({required this.feedbackId});

  Future<Map<String, dynamic>> fetchFeedbackDetails(String feedbackId) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('feedback')
          .doc(feedbackId)
          .get();

      return doc.data() as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching feedback details: $e');
      return {};
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchFeedbackDetails(feedbackId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Feedback Details')),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Feedback Details')),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Feedback Details')),
            body: Center(child: Text('No details available')),
          );
        }

        var feedback = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text('Feedback Details')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vehicle Registration No: ${feedback['vehicleRegNo']}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Rating:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  RatingBar.builder(
                    initialRating: feedback['rating'].toDouble(),
                    minRating: 1,
                    direction: Axis.horizontal,
                    itemCount: 5,
                    itemSize: 30,
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      // Handle rating change if needed
                    },
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Date: ${feedback['date']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Type: ${feedback['type']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Message: ${feedback['message']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
