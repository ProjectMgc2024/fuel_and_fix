import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/owner/screens/owner.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

import 'firebase_options.dart';

Future<void> main() async {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: OwnerIntro()));

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("completes");
}
