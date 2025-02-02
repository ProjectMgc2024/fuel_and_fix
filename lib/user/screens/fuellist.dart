/*import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FuelList extends StatelessWidget {
  final String userId;  // Add userId as a parameter

  FuelList({required this.userId});  // Update constructor to accept userId

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Information'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('fuel')
            .where('userId', isEqualTo: userId)  // Filter by userId
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No fuel information found for this user'));
          }

          return ListView.builder(
            itemCount: snapshot.data?.docs.length,
            itemBuilder: (context, index) {
              var fuelData = snapshot.data?.docs[index];

              return ListTile(
                leading: Image.network(fuelData?['companyLogo']),
                title: Text(fuelData?['companyName']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${fuelData?['email']}'),
                    Text('Owner: ${fuelData?['ownerName']}'),
                    Text('Phone: ${fuelData?['phoneNo']}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/
