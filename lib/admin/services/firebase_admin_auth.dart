import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminAuthServices {
  final firebaseAuth = FirebaseAuth.instance;

  void register(
      {required BuildContext context,
      required String username,
      required int phoneno,
      required String email,
      required String password}) {
    print("$username $phoneno $email $password");
  }
}
