import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TPaymentsAndEarningsPage extends StatefulWidget {
  @override
  _TPaymentsAndEarningsPageState createState() =>
      _TPaymentsAndEarningsPageState();
}

class _TPaymentsAndEarningsPageState extends State<TPaymentsAndEarningsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fetch the current user ID
  Future<String?> getCurrentUserId() async {
    final user = _auth.currentUser;
    return user?.uid;
  }

  // Fetch username by user ID
  Future<String> fetchUsername(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection(
            'user') // Ensure this matches your Firestore collection name
        .doc(userId)
        .get();

    if (userDoc.exists) {
      return userDoc.data()?['username'] ?? 'Unknown User';
    }
    return 'Unknown User';
  }

  // Fetch payment data and include username
  Future<List<Map<String, dynamic>>> fetchPaymentData() async {
    final userId = await getCurrentUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('tow')
        .doc(userId) // Use the current user's ID as the document ID
        .collection('request')
        .where('isPayment', isEqualTo: true)
        .get();

    // Fetch payment data with username
    List<Map<String, dynamic>> paymentData = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final username = await fetchUsername(data['userId']);
      paymentData.add({
        'paymentId': data['paymentId'],
        'status': data['status'] == true ? 'Successful' : 'Failed',
        'timestamp': data['timestamp'],
        'username': username,
      });
    }
    return paymentData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payments & Earnings'),
        backgroundColor: const Color.fromARGB(255, 111, 150, 146),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPaymentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No payment data found.'));
          }

          final paymentData = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: paymentData.length,
            itemBuilder: (context, index) {
              final payment = paymentData[index];
              return _buildPaymentCard(payment);
            },
          );
        },
      ),
    );
  }

  // Payment card widget
  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment ID: ${payment['paymentId']}',
                style: TextStyle(fontSize: 14, color: Colors.blue)),
            Text('Status: ${payment['status']}',
                style: TextStyle(
                    fontSize: 14,
                    color: payment['status'] == 'Successful'
                        ? Colors.green
                        : Colors.red)),
            Text(
              'Timestamp: ${payment['timestamp'].toDate()}',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            Text('Username: ${payment['username']}',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
