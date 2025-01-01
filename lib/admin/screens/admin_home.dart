import 'package:flutter/material.dart';
import 'package:fuel_and_fix/admin/screens/feedback.dart';
import 'package:fuel_and_fix/admin/screens/fuel.dart';
import 'package:fuel_and_fix/admin/screens/mechanics.dart';
import 'package:fuel_and_fix/admin/screens/users.dart';
import 'package:fuel_and_fix/admin/screens/tow.dart';

class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 115, 123, 134),
        elevation: 6.0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8E9AAF), Color(0xFFEDEDED)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: GridView.count(
          padding: const EdgeInsets.all(16),
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 16,
          children: [
            _gridItem(context, 'User Management', Icons.manage_accounts, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageUser()),
              );
            }),
            _gridItem(context, 'Mechanic Management', Icons.build, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RepairPage()),
              );
            }),
            _gridItem(
                context, 'Fuel Station Management', Icons.local_gas_station,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageFuelStation()),
              );
            }),
            _gridItem(context, 'Tow Management', Icons.directions_car, () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ManageTowStation()),
              );
            }),
            // Feedback section with horizontal movement
            Transform.translate(
              offset: Offset(80, 0), // Adjust the horizontal movement here
              child: _gridItem(context, 'Feedback & Complaints', Icons.feedback,
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => adminfeedback()),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // Grid Item Widget for each Admin Option with custom width and height
  Widget _gridItem(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxWidth: 150, // Custom width
            maxHeight: 150, // Custom height
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFDEE2FF), Color(0xFFECEFF1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blueGrey.withOpacity(0.1),
                child: Icon(icon, color: Colors.blueGrey, size: 30),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
