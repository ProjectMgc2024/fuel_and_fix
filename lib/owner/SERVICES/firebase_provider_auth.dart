import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OwnerAuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Refactored register method to handle both fuel and tow registrations
  Future<void> register({
    required BuildContext context,
    required String email,
    required String password,
    required String phNo,
    required String ownerName,
    required String cname,
    required String clicense,
    required String collection, // Collection name: 'fuel' or 'tow'
  }) async {
    try {
      // Register the user with Firebase Authentication
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if user is created successfully
      if (userCredential.user == null) {
        throw FirebaseAuthException(
            message: 'User registration failed', code: 'USER_CREATION_FAILED');
      }

      String userId = userCredential.user!.uid;

      // Save user data to Firestore (Don't store password directly)
      await firebaseFirestore.collection(collection).doc(userId).set({
        'email': email,
        'companyName': cname,
        'ownerName': ownerName,
        'employees': null, // Can be updated later
        'phoneNo': phNo,
        'CompanyLicense': clicense,
        'fuels': null, // Can be updated later
        'companyLogo':
            'https://res.cloudinary.com/dnywnuawz/image/upload/v1734347001/public/fuel/hhalljykskzcxxhxomhi.png'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful for $email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e); // Log error for debugging

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Registration Unsuccessful for $email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Login method with improved error handling
  Future<bool> fuelLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      // Sign in the user with Firebase Authentication
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore
      final userDoc = await firebaseFirestore
          .collection('fuel') // Ensure the correct collection
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData =
            userDoc.data() as Map<String, dynamic>; // Type casting to Map
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Login Successful! Welcome, ${userData['ownerName']}'),
            backgroundColor: Colors.green,
          ),
        );
        print('User Data: $userData');
        return true; // Login successful
      } else {
        // If the user does not exist in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // User not found in Firestore
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific FirebaseAuth errors
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found with this email.';
          break;
        case 'wrong-password':
          errorMessage = 'Incorrect password.';
          break;
        default:
          errorMessage = 'Login failed. Please try again.';
      }

      print("Error: $errorMessage");

      // Show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Login failed
    } catch (e) {
      // Handle other unexpected errors
      String errorMessage = 'An unexpected error occurred: ${e.toString()}';
      print("Error: $errorMessage");

      // Show the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Unexpected error
    }
  }

  // Method to check if a user is already logged in
  Future<bool> isUserLoggedIn() async {
    final user = firebaseAuth.currentUser;
    return user != null;
  }

  // Method to logout user
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  // Method for repair login
  Future<bool> repairLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore (Assuming repair data is stored in a collection called 'repair')
      final userDoc = await firebaseFirestore
          .collection(
              'repair') // Change this to your correct collection for repairs
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Login Successful! Welcome, ${userData['ownerName']}'),
            backgroundColor: Colors.green,
          ),
        );
        print('User Data: $userData');
        return true; // Login successful
      } else {
        // If the user does not exist in Firestore
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
        default:
          errorMessage = 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Login failed
    } catch (e) {
      String errorMessage = 'An unexpected error occurred: ${e.toString()}';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Unexpected error
    }
  }

  // Tow Login method
  Future<bool> towLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user details from Firestore for Tow collection
      final userDoc = await firebaseFirestore
          .collection('tow') // Make sure to use the correct 'tow' collection
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Login Successful! Welcome, ${userData['ownerName']}'),
            backgroundColor: Colors.green,
          ),
        );
        print('User Data: $userData');
        return true; // Login successful
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the Tow database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false; // User not found in the Firestore 'tow' collection
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
          errorMessage = 'Login failed. Please try again.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false; // Login failed
    } catch (e) {
      String errorMessage = 'An unexpected error occurred: ${e.toString()}';
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
