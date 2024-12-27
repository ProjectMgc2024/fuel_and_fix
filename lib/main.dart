import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fuel_and_fix/admin/screens/admin_home.dart';
import 'package:fuel_and_fix/owner/screens/tow/managetow.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';
import 'package:fuel_and_fix/user/screens/splash.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: IntroductionPage()),
  );
}
