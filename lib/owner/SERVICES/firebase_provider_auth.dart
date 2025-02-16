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
    Map<String, dynamic>? additionalData,
    required String cname,
    required String clicense,
    required String collection, // Collection name: 'fuel' or 'tow' or 'repair'
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw FirebaseAuthException(
            message: 'User registration failed', code: 'USER_CREATION_FAILED');
      }

      String userId = userCredential.user!.uid;

      Map<String, dynamic> userData = {
        'email': email,
        'companyName': cname,
        'ownerName': ownerName,
        'phoneNo': phNo,
        'companyLicense': clicense,
        'additionalData': additionalData,
        'companyLogo':
            'https://res.cloudinary.com/dnywnuawz/image/upload/v1734347001/public/fuel/hhalljykskzcxxhxomhi.png',
        'status': true,
        'isApproved': false,
      };

      if (collection == 'fuel') {
        await firebaseFirestore.collection(collection).doc(userId).set({
          ...userData,
          'employees': null,
          'fuels': null,
          'service': 'fuel',
        });
      } else if (collection == 'tow') {
        await firebaseFirestore.collection(collection).doc(userId).set({
          ...userData,
          'employees': null,
          'servicesOffered': null,
          'service': 'tow',
        });
      } else if (collection == 'repair') {
        await firebaseFirestore.collection(collection).doc(userId).set({
          ...userData,
          'employees': null,
          'vehicleTypes': null,
          'service': 'repair',
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration Successful for $email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print(e);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Registration Unsuccessful for $email: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> fuelLogin({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userDoc = await firebaseFirestore
          .collection('fuel')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        bool isEnabled = userData['status'] ?? false;

        if (!isEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Your fuel station is disabled. Please contact the administrator."),
              backgroundColor: Colors.red,
            ),
          );
          return false; // Account is disabled; do not show success.
        }

        // Simply return true; no success message here.
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

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

      final userDoc = await firebaseFirestore
          .collection('repair')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        bool isEnabled = userData['status'] ?? false;

        if (!isEnabled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  "Your repair shop is disabled. Please contact the administrator."),
              backgroundColor: Colors.red,
            ),
          );
          return false; // Account is disabled
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Login Successful! Welcome, ${userData['ownerName']}'),
            backgroundColor: Colors.green,
          ),
        );
        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e.code);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

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

      final userDoc = await firebaseFirestore
          .collection('tow')
          .doc(userCredential.user?.uid)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        bool isEnabled = userData['status'] ?? false;

        return true;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not found in the database.'),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseAuthErrorMessage(e.code);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  Future<bool> isUserLoggedIn() async {
    return firebaseAuth.currentUser != null;
  }

  String _getFirebaseAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
