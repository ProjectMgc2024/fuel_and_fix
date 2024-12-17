import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserAuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore FirebaseDatabase = FirebaseFirestore.instance;

  Future<void> register({
    required BuildContext context,
    required String username,
    required String phoneno,
    required String email,
    required String password,
    required String location,
    required String license,
    required String registrationNo,
    required String vehicleType,
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
        'location': location,
        'license': license,
        'registrationNo': registrationNo,
        'vehicleType': vehicleType
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
      final userDoc = await FirebaseFirestore.instance
          .collection('user') // Assuming you have a 'user' collection
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
        // If the user does not exist in Firestore, show an error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // User not found in Firestore
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
        case 'Login failed: The supplied auth credential is incorrect, malformed or has expired.':
          errorMessage = 'user not found';
          break;
        default:
          errorMessage =
              'User not found in the database. Please register first.';
      }

      // Print the error message
      print("Error: $errorMessage");

      // Show the error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Login failed
    } catch (e) {
      // Handle other errors
      String errorMessage = 'An unexpected error occurred: ${e.toString()}';
      print("Error: $errorMessage"); // Print the error

      // Show the error message in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Unexpected error
    }
  }
}
