import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback'),
        backgroundColor: Color.fromARGB(255, 160, 128, 39),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('feedback').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No feedback available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var feedbackData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;
              String serviceName = feedbackData['service'] ?? 'Unknown Service';

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(serviceName,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Tap to view details'),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ServiceDetailsPage(serviceName: serviceName),
                    ),
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

class ServiceDetailsPage extends StatelessWidget {
  final String serviceName;

  ServiceDetailsPage({required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$serviceName Details'),
        backgroundColor: Color.fromARGB(255, 160, 128, 39),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(serviceName).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No details available for $serviceName.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var detailData =
                  snapshot.data!.docs[index].data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text(detailData['title'] ?? 'No Title',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(detailData['description'] ?? 'No Description'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
