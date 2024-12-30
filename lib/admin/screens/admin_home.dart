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
        title: Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 145, 155, 118),
        elevation: 4.0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dashboard Section
              _sectionCard(
                context,
                'User Management',
                Icons.manage_accounts,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageUser()),
                  );
                },
              ),
              _sectionCard(
                context,
                'Mechanic Management',
                Icons.build,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RepairPage()),
                  );
                },
              ),
              _sectionCard(
                context,
                'Fuel Station Management',
                Icons.local_gas_station,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ManageFuelStation()),
                  );
                },
              ),
              _sectionCard(
                context,
                'Tow Management',
                Icons.directions_car,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ManageTowStation()),
                  );
                },
              ),
              _sectionCard(
                context,
                'Feedback and Complaints',
                Icons.feedback,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => adminfeedback()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Section Card Widget for each Admin Option
  Widget _sectionCard(
      BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueGrey, size: 30),
        title: Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing:
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blueGrey),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}

// Sample Pages for Navigation (These pages will be placeholders for now)

class ManageUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Users')),
      body: Center(child: Text('Manage Users Content')),
    );
  }
}

class ManageMechanicsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Mechanics')),
      body: Center(child: Text('Manage Mechanics Content')),
    );
  }
}

class ManageFuelStationsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Manage Fuel Stations')),
      body: Center(child: Text('Manage Fuel Stations Content')),
    );
  }
}

class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transactions')),
      body: Center(child: Text('Transactions Content')),
    );
  }
}

class ReportsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reports')),
      body: Center(child: Text('Reports Content')),
    );
  }
}

class FeedbackPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Feedback and Complaints')),
      body: Center(child: Text('Feedback and Complaints Content')),
    );
  }
}
