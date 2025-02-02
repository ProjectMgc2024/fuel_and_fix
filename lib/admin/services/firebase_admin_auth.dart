import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminAuthServices {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  // Fetch all users from Firestore
  Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await firebaseFirestore.collection('user').get();
      List<Map<String, dynamic>> userList = querySnapshot.docs.map((doc) {
        return {'id': doc.id, ...doc.data() as Map<String, dynamic>};
      }).toList();
      return userList;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  // Update user status (enabled/disabled)
  Future<void> updateUserStatus(String userId, bool disabled) async {
    try {
      await firebaseFirestore.collection('user').doc(userId).update({
        'disabled': disabled,
      });
      print('User status updated successfully.');
    } catch (e) {
      print('Error updating user status: $e');
      throw e;
    }
  }

  // Delete a user from Firestore
  Future<void> deleteUser(String userId) async {
    try {
      await firebaseFirestore.collection('user').doc(userId).delete();
      print('User with ID $userId deleted successfully.');
    } catch (e) {
      print('Error deleting user: $e');
    }
  }

  // Fetch all feedback from Firestore
  Future<List<Map<String, dynamic>>> fetchAllFeedback() async {
    try {
      QuerySnapshot querySnapshot =
          await firebaseFirestore.collection('feedback').get();
      List<Map<String, dynamic>> feedbackList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID
          ...doc.data() as Map<String, dynamic> // Feedback data
        };
      }).toList();
      return feedbackList;
    } catch (e) {
      print('Error fetching feedback: $e');
      return [];
    }
  }

  // Delete feedback from Firestore
  Future<void> deleteFeedback(String feedbackId) async {
    try {
      await firebaseFirestore.collection('feedback').doc(feedbackId).delete();
      print('Feedback with ID $feedbackId deleted successfully.');
    } catch (e) {
      print('Error deleting feedback: $e');
    }
  }
}
