import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/admin/screens/admin_home.dart';

import 'firebase_options.dart';

Future<void> main() async {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AdminPage()));

// ...

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  print("completes");
}
