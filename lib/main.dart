import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/user/screens/login_screen.dart';

import 'package:fuel_and_fix/user/screens/profile.dart';

import 'firebase_options.dart';

Future<void> main() async {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ProfileScree()));

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("completes");
}
