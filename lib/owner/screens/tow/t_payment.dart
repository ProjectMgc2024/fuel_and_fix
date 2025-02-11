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

  @override
  Widget build(BuildContext context) {
    // Access the current user synchronously (assumes user is already authenticated)
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Payments & Earnings')),
        body: Center(child: Text('User not logged in.')),
      );
    }
    final userId = currentUser.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text('Payments & Earnings'),
        backgroundColor: const Color.fromARGB(255, 111, 150, 146),
      ),
      // Listen to the payment documents from the tow/request subcollection.
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tow')
            .doc(userId)
            .collection('request')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // Show error message if any error occurs.
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(child: Text('No payment data found.'));
          }
          // Build the list of PaymentCard widgets.
          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              return PaymentCard(data: data);
            },
          );
        },
      ),
    );
  }
}

// PaymentCard widget that displays a payment record.
// It fetches the user details in initState and displays those fields only when they are available.
class PaymentCard extends StatefulWidget {
  final Map<String, dynamic> data;
  const PaymentCard({Key? key, required this.data}) : super(key: key);

  @override
  _PaymentCardState createState() => _PaymentCardState();
}

class _PaymentCardState extends State<PaymentCard> {
  String? username;
  String? phoneno;
  String? email;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  // Fetch user details from the 'user' collection.
  Future<void> _fetchUserDetails() async {
    final userId = widget.data['userId'] ?? '';
    if (userId.isEmpty) return;
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(userId).get();
    if (userDoc.exists) {
      final data = userDoc.data();
      setState(() {
        username = data?['username'];
        phoneno = data?['phoneno'];
        email = data?['email'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentId = widget.data['paymentId'] ?? 'N/A';
    final isPaid = (widget.data['isPaid'] == true) ? 'Successful' : 'Failed';
    final timestamp = widget.data['timestamp'];
    final userLocation = widget.data['userLocation'] ?? 'Unknown Location';
    final vehicleSituation = widget.data['vehicleSituation'] ?? 'Unknown';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Payment ID: $paymentId',
                style: TextStyle(fontSize: 14, color: Colors.blue)),
            SizedBox(height: 4),
            Text(
              'isPaid: $isPaid',
              style: TextStyle(
                  fontSize: 14,
                  color: isPaid == 'Successful' ? Colors.green : Colors.red),
            ),
            SizedBox(height: 4),
            Text(
              'Timestamp: ${timestamp != null ? (timestamp as Timestamp).toDate() : 'N/A'}',
              style: TextStyle(fontSize: 14, color: Colors.black45),
            ),
            SizedBox(height: 4),
            // Display user details only if they are available.
            if (username != null)
              Text('Username: $username',
                  style: TextStyle(fontSize: 14, color: Colors.black45)),
            SizedBox(height: 4),
            if (phoneno != null)
              Text('Phone: $phoneno',
                  style: TextStyle(fontSize: 14, color: Colors.black45)),
            SizedBox(height: 4),
            if (email != null)
              Text('Email: $email',
                  style: TextStyle(fontSize: 14, color: Colors.black45)),
            SizedBox(height: 4),
            Text('Location: $userLocation',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
            SizedBox(height: 4),
            Text('Vehicle Situation: $vehicleSituation',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
