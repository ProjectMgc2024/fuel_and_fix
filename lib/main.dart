import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/owner/screens/tow_profile.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(
      MaterialApp(debugShowCheckedModeBanner: false, home: TowProfilePage()));

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("completes");
}
