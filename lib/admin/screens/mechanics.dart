import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RepairPage extends StatefulWidget {
  @override
  _RepairPageState createState() => _RepairPageState();
}

class _RepairPageState extends State<RepairPage> {
  List<Map<String, dynamic>> repairShops = [];

  @override
  void initState() {
    super.initState();
    _fetchRepairShops(); // Fetch the repair shops when the page is loaded
  }

  // Fetch repair shops data from Firestore
  Future<void> _fetchRepairShops() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('repair').get();
      List<Map<String, dynamic>> repairList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      setState(() {
        repairShops = repairList;
      });
    } catch (e) {
      print('Error fetching repair shops: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Repair Shops'),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Repair Shops List Header
              Text(
                'List of Repair Shops',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 15),

              // Repair Shops List
              Expanded(
                child: repairShops.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: repairShops.length,
                        itemBuilder: (context, index) {
                          return _repairShopCard(
                            context,
                            repairShops[index]['companyName'] ?? 'Unknown',
                            repairShops[index]['email'] ?? 'Unknown',
                            repairShops[index]['phoneNo'] ?? 'Unknown',
                            repairShops[index]['status'] ?? false,
                            repairShops[index]['employees'] ?? [],
                            index,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Repair Shop Card Widget
  Widget _repairShopCard(BuildContext context, String companyName, String email,
      String phoneNo, bool status, List employees, int index) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: Colors.deepPurple,
          backgroundImage:
              NetworkImage(repairShops[index]['companyLogo'] ?? ''),
        ),
        title: Text(
          companyName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.deepPurpleAccent,
          ),
        ),
        subtitle: Text(
          'Email: $email\nPhone: $phoneNo\nStatus: ${status ? 'Active' : 'Inactive'}',
          style: TextStyle(color: Colors.black54),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
        onTap: () {
          // Navigate to RepairShopDetailPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RepairShopDetailPage(
                companyName: companyName,
                email: email,
                phoneNo: phoneNo,
                status: status,
                employees: employees,
              ),
            ),
          );
        },
      ),
    );
  }
}

class RepairShopDetailPage extends StatelessWidget {
  final String companyName;
  final String email;
  final String phoneNo;
  final bool status;
  final List employees;

  const RepairShopDetailPage({
    required this.companyName,
    required this.email,
    required this.phoneNo,
    required this.status,
    required this.employees,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(companyName),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Repair Shop Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Email: $email',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: $phoneNo',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Status: ${status ? 'Active' : 'Inactive'}',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 15),
            Text(
              'Employees:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            employees.isEmpty
                ? Text('No employees available')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: employees.length,
                    itemBuilder: (context, index) {
                      final employee = employees[index];
                      return ListTile(
                        title: Text(employee['employeeName'] ?? 'Unknown'),
                        subtitle: Text(
                          'Role: ${employee['employeeRole'] ?? 'Unknown'}\nPhone: ${employee['employeePhoneNo'] ?? 'Unknown'}',
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
