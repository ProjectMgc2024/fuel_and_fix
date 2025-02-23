import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Flag to prevent multiple navigations
  bool _isNavigating = false;
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";

  // Use a batch update to mark all unread notifications as read.
  Future<void> markNotificationsAsRead() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .get();

    var batch = FirebaseFirestore.instance.batch();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Background image and dark overlay
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'asset/pic2.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Dark overlay
          Positioned.fill(
            child: Container(
              color: const Color.fromARGB(255, 25, 15, 12).withOpacity(0.4),
            ),
          ),
          // Main content: AppBar and Body
          Column(
            children: [
              appBarSection(),
              Expanded(child: bodyContent(context)),
            ],
          ),
          // Footer Icons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Home Icon
                  IconButton(
                    iconSize: 25,
                    icon: Icon(Icons.home, color: Colors.white),
                    onPressed: () {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AboutHelp()),
                      );
                    },
                  ),
                  // Notification Icon with Badge
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('notifications')
                        .where('userId', isEqualTo: currentUserId)
                        .where('read', isEqualTo: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      int unreadCount = 0;
                      if (snapshot.hasData) {
                        unreadCount = snapshot.data!.docs.length;
                      }
                      return Stack(
                        children: [
                          IconButton(
                            iconSize: 25,
                            icon: Icon(Icons.notifications,
                                color: const Color.fromARGB(255, 217, 223, 33)),
                            onPressed: () async {
                              if (!_isNavigating) {
                                setState(() {
                                  _isNavigating = true;
                                });
                                await markNotificationsAsRead();
                                // Navigate to UserNotificationPage on first tap
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UserNotificationPage()),
                                );
                                // When coming back, allow navigation again.
                                setState(() {
                                  _isNavigating = false;
                                });
                              }
                            },
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                constraints: BoxConstraints(
                                  minWidth: 14,
                                  minHeight: 14,
                                ),
                                child: Text(
                                  '$unreadCount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Chat Button positioned above the footer
          Positioned(
            bottom: 60,
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
        automaticallyImplyLeading: false, // Remove back button
        title: Text(
          'Fuel & Fix Assist System',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 25,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(184, 28, 8, 8),
        elevation: 10,
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FetchLocationPopup(
                        serviceType: '',
                      ),
                    ),
                  ).then((value) {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchLocationPopup(
                              serviceType: '',
                            )),
                  ).then((value) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkshopScreen()),
                    );
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 30),
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FetchLocationPopup(
                              serviceType: '',
                            )),
                  ).then((value) {
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
