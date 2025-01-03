import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

import 'firebase_options.dart';

const apikey = 'AIzaSyB-ndnn8GCm_bYpD6qhJcYZf8twGd4OowA';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Gemini.init(apiKey: apikey);

  runApp(
    MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
  );
}
