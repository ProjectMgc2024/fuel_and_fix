import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/about.dart';
import 'package:fuel_and_fix/user/screens/chatbot.dart';
import 'package:fuel_and_fix/user/screens/currentlocation.dart';
import 'package:fuel_and_fix/user/screens/fuel.dart';
import 'package:fuel_and_fix/user/screens/history.dart';
import 'package:fuel_and_fix/user/screens/message.dart';
import 'package:fuel_and_fix/user/screens/profile.dart';
import 'package:fuel_and_fix/user/screens/repair.dart';
import 'package:fuel_and_fix/user/screens/tow.dart';
import 'package:fuel_and_fix/user/screens/viewfeedback.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold Background set to the image
      body: Stack(
        children: [
          // Background Image (No blur effect, only opacity)
          Positioned.fill(
            child: Image.asset(
              'asset/pic2.jpg', // Your image asset
              fit: BoxFit.cover, // Ensure the image covers the screen
            ),
          ),
          // Dark overlay to simulate the blur effect
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 25, 15, 12)
                  .withOpacity(0.4), // Darken the background
            ),
          ),
          // Main content of the screen (AppBar and options)
          Column(
            children: [
              // AppBar section
              appBarSection(),
              // Body content
              Expanded(child: bodyContent(context)),
            ],
          ),
          // Manually positioned icons at the bottom (without footer bar)
          Positioned(
            bottom: 0, // Positioning at the bottom of the screen
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0), // Padding around the icons
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home Icon
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () {
                      // Navigate to HomePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  // Profile Icon
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.account_circle,
                        color: const Color.fromARGB(255, 93, 180, 53)),
                    onPressed: () {
                      // Navigate to ProfilePage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ProfileScreen()),
                      );
                    },
                  ),
                  // History Icon
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.history,
                        color: const Color.fromARGB(255, 255, 136, 136)),
                    onPressed: () {
                      // Navigate to HistoryPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderHistoryPage()),
                      );
                    },
                  ),
                  // Feedback Icon
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.feedback,
                        color: const Color.fromARGB(255, 165, 162, 97)),
                    onPressed: () {
                      // Navigate to ViewFeedbackPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewFeedbackPage()),
                      );
                    },
                  ),
                  // About/Help Icon
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.help,
                        color: const Color.fromARGB(255, 132, 146, 255)),
                    onPressed: () {
                      // Navigate to AboutPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutHelp()),
                      );
                    },
                  ),
                  // Notification Icon (new icon)
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.notifications,
                        color: const Color.fromARGB(255, 217, 223, 33)),
                    onPressed: () {
                      // Navigate to NotificationPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                UserNotificationPage()), // Add your notification page here
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Chat Button positioned above the bottom navigation bar
          Positioned(
            bottom: 60, // Position above the bottom navigation bar
            right: 10,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AiChatPage()),
                );
              },
              child: Image.asset(
                'asset/ar.jpg',
                width: 60,
                height: 90,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar Section
  PreferredSize appBarSection() {
    return PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: AppBar(
        automaticallyImplyLeading: false, // This will remove the back button
        title: Text(
          'Fuel & Fix Assist System',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: const Color.fromARGB(
                255, 255, 255, 255), // Set text color to white
            fontSize: 25,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(184, 28, 8, 8),
        elevation: 10,
        // Add slight shadow to AppBar
      ),
    );
  }

  // Body content of the page
  Widget bodyContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // First Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildOptionBox(
                context: context,
                title: 'Fuel',
                icon: Icons.local_gas_station,
                colors: [
                  Color.fromARGB(197, 58, 7, 7),
                  Color.fromARGB(255, 39, 35, 36),
                ],
                onTap: () {
                  // Navigate to FetchLocationPopup first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FetchLocationPopup(
                        serviceType: '',
                      ),
                    ),
                  ).then((value) {
                    // After FetchLocationPopup, proceed to FuelScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => FuelStationList()),
                    );
                  });
                },
              ),
              buildOptionBox(
                context: context,
                title: 'Repair Services',
                icon: Icons.build,
                colors: [
                  Color.fromARGB(197, 67, 3, 3),
                  Color.fromARGB(255, 45, 39, 39),
                ],
                onTap: () {
                  // Navigate to FetchLocationPopup first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchLocationPopup(
                              serviceType: '',
                            )),
                  ).then((value) {
                    // After FetchLocationPopup, proceed to WorkshopScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkshopScreen()),
                    );
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 30), // Space between rows
          // Second Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              buildOptionBox(
                context: context,
                title: 'Tow Services',
                icon: Icons.drive_eta,
                colors: [
                  Color.fromARGB(197, 58, 7, 7),
                  Color.fromARGB(255, 39, 35, 36),
                ],
                onTap: () {
                  // Navigate to FetchLocationPopup first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchLocationPopup(
                              serviceType: '',
                            )),
                  ).then((value) {
                    // After FetchLocationPopup, proceed to TowingServiceCategories
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TowingServiceCategories()),
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Option box widget for each service option
  Widget buildOptionBox({
    required BuildContext context,
    required String title,
    required IconData icon,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(6, 8),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 35,
              ),
              SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: Offset(2, 2),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
