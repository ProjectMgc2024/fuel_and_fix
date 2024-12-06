import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseDatabase = FirebaseFirestore.instance;

  Future<void> register({
    required BuildContext context,
    required String username,
    required String phoneno,
    required String email,
    required String password,
  }) async {
    try {
      // Register the user

      final user = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await FirebaseDatabase.collection('user').doc(user.user?.uid).set({
        'username': username,
        'phoneno': phoneno,
        'email': email,
        'password': password
      });
      print(user.user?.uid);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful for $username'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Registration Unsuccessful for $username: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
