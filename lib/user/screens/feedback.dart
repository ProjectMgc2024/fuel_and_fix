import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final String stationId;
  final String stationName;
  final String service;
  final String? userId;

  FeedbackScreen({
    required this.stationId,
    required this.stationName,
    required this.service,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    TextEditingController feedbackController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback for $stationName'),
        backgroundColor:
            Color.fromARGB(255, 201, 161, 76), // Golden color for AppBar
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              Text(
                'We value your feedback! Please provide your thoughts below:',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 30), // Increased space before the input box

              // Feedback Input Field
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 4), // Shadow position
                    ),
                  ],
                ),
                child: TextField(
                  controller: feedbackController,
                  maxLines: 6,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter your feedback here...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              SizedBox(height: 20), // Space between the feedback box and button

              // Submit Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 201, 161, 76), // Golden color for button
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 6,
                ),
                onPressed: () async {
                  // Check if feedback is empty
                  if (feedbackController.text.isEmpty) {
                    // Show a message in the feedback box if empty
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          Text('Please enter your feedback before submitting.'),
                      backgroundColor: Colors.red,
                    ));
                    return; // Don't submit if feedback is empty
                  }

                  // Add feedback to Firebase
                  await FirebaseFirestore.instance.collection('feedback').add({
                    'feedback': feedbackController.text,
                    'timestamp': Timestamp.now(),
                    'service': service,
                    'ownerId': stationId,
                    'userId': userId,
                  });

                  // Show confirmation and pop the screen
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Feedback submitted successfully!'),
                  ));
                  Navigator.pop(context);
                },
                child: Text(
                  'Submit Feedback',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
