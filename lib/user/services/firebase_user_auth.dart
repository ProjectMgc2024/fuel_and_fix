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

  Future<bool> userLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user with email and password
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore
      final userDoc = await FirebaseDatabase.collection('user')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Login Successful! Welcome, ${userData?['username']}'),
            backgroundColor: Colors.green,
          ),
        );
        print('User Data: ${userData}');
        return true; // Login successful
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // User not found
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Login failed
    } catch (e) {
      // Handle other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An unexpected error occurred: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Unexpected error
    }
  }
}
