import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_and_fix/owner/screens/feedbackview.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_request.dart';
import 'package:fuel_and_fix/owner/screens/fuel/f_payment.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_profile.dart';
import 'package:fuel_and_fix/owner/screens/owner.dart';
import 'package:fuel_and_fix/user/screens/introduction.dart';

class FuelManagement extends StatefulWidget {
  @override
  _FuelManagementState createState() => _FuelManagementState();
}

class _FuelManagementState extends State<FuelManagement> {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  int pendingRequestCount = 0;

  @override
  void initState() {
    super.initState();
    fetchPendingRequestCount();
  }

  // Listen for fuel requests where read is false.
  // The snapshot listener updates the badge in real time.
  void fetchPendingRequestCount() {
    FirebaseFirestore.instance
        .collection('fuel')
        .doc(currentUserId)
        .collection('request')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
      setState(() {
        pendingRequestCount = snapshot.docs.length;
      });
    });
  }

  // When the Fuel Requests tile is tapped, query the pending requests.
  // If any exist, show the count in a SnackBar and mark each as read (set read to true).
  // The badge is cleared only after Firestore confirms the updates.
  void clearPendingRequests() async {
    QuerySnapshot pendingSnapshot = await FirebaseFirestore.instance
        .collection('fuel')
        .doc(currentUserId)
        .collection('request')
        .where('read', isEqualTo: false)
        .get();

    int count = pendingSnapshot.docs.length;
    if (count > 0) {
      // Display the count in a SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'You have $count new fuel request(s). Marking them as read.'),
        ),
      );
      // Mark all pending requests as read by updating 'read' to true.
      // We await each update so the UI badge remains until Firestore confirms the change.
      for (var doc in pendingSnapshot.docs) {
        await doc.reference.update({'read': true});
      }
      // No manual setState here—once Firestore is updated,
      // the snapshot listener in fetchPendingRequestCount() clears the badge.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => OwnerIntro()),
              );
            }),
        centerTitle: true,
        title: Text(
          'Fuel Management',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 137, 152, 108),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, size: 30),
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text('Logged out!')));
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => IntroductionPage()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 176, 179, 163),
              const Color.fromARGB(255, 96, 85, 62),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: ListView(
            children: [
              _buildDashboardSection(
                context,
                'Profile',
                'Update your provider details',
                Icons.person,
                FuelProfilePage(),
              ),
              _buildDashboardSection(
                context,
                'Fuel Requests',
                'Manage incoming fuel service requests',
                Icons.local_gas_station,
                FuelFillingRequest(),
                pendingRequestCount,
                clearPendingRequests,
              ),
              _buildDashboardSection(
                context,
                'Payments & Earnings',
                'Track your fuel service payments',
                Icons.account_balance_wallet,
                PaymentsAndEarningsPage(),
              ),
              _buildDashboardSection(
                context,
                'Feedback',
                'View and manage customer feedback',
                Icons.feedback,
                FeedbackScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardSection(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Widget page, [
    int? notificationCount,
    VoidCallback? onTap,
  ]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap();
          }
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 106, 107, 69),
                Color.fromRGBO(85, 63, 52, 1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      description,
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              if (notificationCount != null && notificationCount > 0)
                CircleAvatar(
                  backgroundColor: Colors.red,
                  radius: 13,
                  child: Text(
                    notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
