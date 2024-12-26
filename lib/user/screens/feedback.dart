import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FeedbackScreen extends StatelessWidget {
  final String stationId;
  final String stationName;
  final String service;
  final String? userId;

  FeedbackScreen(
      {required this.stationId,
      required this.stationName,
      required this.service,
      required this.userId});

  @override
  Widget build(BuildContext context) {
    TextEditingController feedbackController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback for $stationName'),
        backgroundColor: const Color.fromARGB(255, 206, 137, 59),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please provide your feedback below:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Feedback',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Add feedback to Firebase or wherever necessary
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
              child: Text('Submit Feedback'),
            ),
          ],
        ),
      ),
    );
  }
}
