import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/admin/screens/admin_home.dart';
import 'package:fuel_and_fix/owner/screens/owner.dart';
import 'package:fuel_and_fix/owner/screens/repair/managerepair.dart';
import 'package:fuel_and_fix/owner/screens/repair/repair_request.dart';
import 'package:fuel_and_fix/user/screens/fuel.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';

import 'package:fuel_and_fix/user/screens/introduction.dart';
import 'package:fuel_and_fix/user/screens/repair.dart';
import 'package:fuel_and_fix/user/screens/splash.dart';

import 'firebase_options.dart';
import 'user/screens/profile.dart';

Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OwnerIntro(),
    ),
  );
}
