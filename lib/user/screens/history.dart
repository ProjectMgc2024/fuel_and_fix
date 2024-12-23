import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class userHistory extends StatefulWidget {
  @override
  _userHistoryState createState() => _userHistoryState();
}

class _userHistoryState extends State<userHistory> {
  late String currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
  }

  // Get the current user's ID
  Future<void> _getCurrentUserId() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId.isEmpty) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Request Details')),
      body: StreamBuilder<QuerySnapshot>(
        // Fetching only the fields ownerId and status
        stream: FirebaseFirestore.instance
            .collection('request')
            .where('userId', isEqualTo: currentUserId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No request found for this user.'));
          }

          final request = snapshot.data!.docs[0];
          final ownerId = request['ownerId'];
          final status = request['status'] ? 'true' : 'false';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Owner ID: $ownerId', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Status: $status',
                    style: TextStyle(
                        fontSize: 18,
                        color:
                            status == 'Accepted' ? Colors.green : Colors.red)),
              ],
            ),
          );
        },
      ),
    );
  }
}
