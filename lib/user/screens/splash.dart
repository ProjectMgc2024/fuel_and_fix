import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double opacity = 0.0;
  double scale = 0.7;

  @override
  void initState() {
    super.initState();

    // Start fading in and scaling the logo after a short delay
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacity = 1.0; // Fade in effect after 0.5 seconds
        scale = 1.5; // Grow the logo slightly to give a nice effect
      });
    });

    // Set a delay to navigate to the next screen
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => IntroductionPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background gradient for a modern look
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color.fromARGB(220, 0, 0, 0),
              const Color.fromARGB(255, 0, 43, 111),
              const Color.fromARGB(255, 112, 75, 0),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Centered logo animation
            Center(
              child: AnimatedOpacity(
                opacity: opacity,
                duration: Duration(seconds: 1),
                child: AnimatedScale(
                  scale: scale,
                  duration: Duration(seconds: 1),
                  child: ClipOval(
                    child: Image.asset(
                      "asset/pic01.jpg", // Your image path
                      width: 200.0, // Adjusted width for a larger logo
                      height: 200.0, // Adjusted height for a larger logo
                      fit: BoxFit
                          .cover, // Make the image cover the entire circle
                    ),
                  ),
                ),
              ),
            ),
            // Text at the bottom center
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 30.0), // Add space from bottom
                child: Text(
                  "Fuel & Fix",
                  style: TextStyle(
                    fontSize: 18.0, // Adjust the size as per your need
                    fontWeight: FontWeight.bold, // You can customize this
                    color: Colors.blue, // Set text color to white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
