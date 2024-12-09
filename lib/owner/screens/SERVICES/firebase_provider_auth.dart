import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerAuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase = FirebaseFirestore.instance;

  Future<void> register({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Register the user

      final owner = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseDatabase.collection('service')
          .doc(owner.user?.uid)
          .set({'email': email, 'password': password});
      print(owner.user?.uid);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('login Successful for $email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('login Unsuccessful for $email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

   
}


