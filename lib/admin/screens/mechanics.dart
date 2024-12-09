import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_and_fix/admin/services/firebase_admin_auth.dart';

class MechanicPage extends StatefulWidget {
  @override
  _MechanicPageState createState() => _MechanicPageState();
}

class _MechanicPageState extends State<MechanicPage> {
  final AdminAuthServices _authServices = AdminAuthServices();
  List<Map<String, dynamic>> workshops = [];

  @override
  void initState() {
    super.initState();
    _fetchWorkshops(); // Fetch the workshops when the page is loaded
  }

  // Fetch workshops data from Firestore
  Future<void> _fetchWorkshops() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('workShop').get();
      List<Map<String, dynamic>> workshopList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
      setState(() {
        workshops = workshopList;
      });
    } catch (e) {
      print('Error fetching workshops: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Mechanics'),
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
              // Mechanic List Header
              Text(
                'List of Workshops',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 15),

              // Workshop List
              Expanded(
                child: workshops.isEmpty
                    ? Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: workshops.length,
                        itemBuilder: (context, index) {
                          return _workshopCard(
                            context,
                            workshops[index]['shopName']!,
                            workshops[index]['shopId']!,
                            workshops[index]['status']!,
                            workshops[index]['workers'] ?? [],
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

  // Workshop Card Widget
  Widget _workshopCard(BuildContext context, String name, String shopId,
      String status, List workers, int index) {
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
          child: Icon(Icons.local_car_wash, color: Colors.white),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.deepPurpleAccent,
          ),
        ),
        subtitle: Text(
          'Shop ID: $shopId\nStatus: $status',
          style: TextStyle(color: Colors.black54),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Edit') {
              _showEditWorkshopDialog(
                  context, name, shopId, status, workers, index);
            } else if (value == 'Delete') {
              _confirmDeleteWorkshop(context, name, index);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(value: 'Edit', child: Text('Edit')),
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ];
          },
        ),
        onTap: () {
          // Navigate to WorkshopDetailPage
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkshopDetailPage(
                name: name,
                shopId: shopId,
                status: status,
                workers: workers,
              ),
            ),
          );
        },
      ),
    );
  }

  // Edit Workshop Dialog
  void _showEditWorkshopDialog(BuildContext context, String name, String shopId,
      String status, List workers, int index) {
    // This function can be implemented later
  }

  // Confirm Delete Workshop
  void _confirmDeleteWorkshop(BuildContext context, String name, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[800],
          title: Text(
            'Delete Workshop',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete $name?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel',
                  style: TextStyle(color: Colors.deepPurpleAccent)),
            ),
            TextButton(
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('workShop')
                    .doc(workshops[index]['id'])
                    .delete();
                setState(() {
                  workshops.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class WorkshopDetailPage extends StatelessWidget {
  final String name;
  final String shopId;
  final String status;
  final List workers;

  const WorkshopDetailPage({
    required this.name,
    required this.shopId,
    required this.status,
    required this.workers,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workshop Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurpleAccent,
              ),
            ),
            SizedBox(height: 15),
            Text(
              'Shop ID: $shopId',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text(
              'Status: $status',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            SizedBox(height: 15),
            Text(
              'Workers:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 10),
            workers.isEmpty
                ? Text('No workers available')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: workers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(workers[index]),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
