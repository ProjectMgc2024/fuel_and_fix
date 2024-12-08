import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/owner/screens/owner_home.dart';
import 'package:fuel_and_fix/owner/screens/r_payment.dart';
import 'package:fuel_and_fix/owner/screens/t_payment.dart';

import 'firebase_options.dart';

Future<void> main() async {
  runApp(
      MaterialApp(debugShowCheckedModeBanner: false, home: ServiceHomePage()));

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("completes");
}
