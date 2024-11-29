import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ManageFeedbackPage(),
    );
  }
}

class ManageFeedbackPage extends StatefulWidget {
  @override
  _ManageFeedbackPageState createState() => _ManageFeedbackPageState();
}

class _ManageFeedbackPageState extends State<ManageFeedbackPage> {
  List<Map<String, String>> feedbackList = [
    {
      'vehicleRegNo': 'KL12AB1234', // Unique vehicle registration number
      'date': '2024-11-01 10:30:00',
      'type': 'Feedback',
      'message': 'Great app!',
      'status': 'Pending',
      'isImportant': 'false',
    },
    {
      'vehicleRegNo':
          'KL12CD5678', // Another unique vehicle registration number
      'date': '2024-11-02 11:00:00',
      'type': 'Complaint',
      'message': 'App crashes frequently',
      'status': 'Resolved',
      'isImportant': 'true',
    },
    {
      'vehicleRegNo': 'KL12XY6789',
      'date': '2024-11-03 14:00:00',
      'type': 'Complaint',
      'message': 'Payment failed multiple times.',
      'status': 'Pending',
      'isImportant': 'true',
    },
  ];

  // Method to delete feedback based on vehicle registration number
  void deleteFeedback(String vehicleRegNo) {
    setState(() {
      feedbackList
          .removeWhere((feedback) => feedback['vehicleRegNo'] == vehicleRegNo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Feedback and Complaints'),
      ),
      body: ListView.builder(
        itemCount: feedbackList.length,
        itemBuilder: (context, index) {
          var feedback = feedbackList[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text('Vehicle: ${feedback['vehicleRegNo']}'),
              subtitle: Text('Status: ${feedback['status']}'),
              trailing: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => deleteFeedback(feedback['vehicleRegNo']!),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FeedbackDetailPage(
                        feedbackList: feedbackList,
                        vehicleRegNo: feedback['vehicleRegNo']!),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class FeedbackDetailPage extends StatelessWidget {
  final List<Map<String, String>> feedbackList;
  final String vehicleRegNo;

  FeedbackDetailPage({required this.feedbackList, required this.vehicleRegNo});

  @override
  Widget build(BuildContext context) {
    // Find the feedback or complaint using vehicleRegNo
    var feedback =
        feedbackList.firstWhere((f) => f['vehicleRegNo'] == vehicleRegNo);

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback/Complaint Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Registration No: ${feedback['vehicleRegNo']}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Date: ${feedback['date']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Type: ${feedback['type']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Message: ${feedback['message']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Status: ${feedback['status']}',
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Important: ${feedback['isImportant']}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
