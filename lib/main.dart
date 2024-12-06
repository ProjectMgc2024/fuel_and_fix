import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/repair_request.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/user/screens/otp.dart';
import 'package:fuel_and_fix/user/screens/register.dart';
import 'firebase_options.dart';

Future<void> main() async {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Register()));

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("completes");
}
