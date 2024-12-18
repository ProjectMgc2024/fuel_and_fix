import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleRepairCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vehicle Repair Services',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Color.fromARGB(255, 83, 89, 162),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: WorkshopListScreen(),
      ),
    );
  }
}

class WorkshopListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('repair')
          .where('status', isEqualTo: true)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final workshops = snapshot.data?.docs ?? [];
        if (workshops.isEmpty) {
          return Center(child: Text('No active workshops available.'));
        }

        return ListView.builder(
          itemCount: workshops.length,
          itemBuilder: (context, index) {
            final workshop = workshops[index];
            return WorkshopCard(workshop: workshop);
          },
        );
      },
    );
  }
}

class WorkshopCard extends StatelessWidget {
  final QueryDocumentSnapshot workshop;

  WorkshopCard({required this.workshop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => RequestDialog(workshop: workshop),
        );
      },
      child: Card(
        margin: EdgeInsets.all(12),
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(243, 21, 30, 108),
                Color.fromARGB(255, 90, 23, 23),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  workshop['companyName'] ?? 'No Name',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 15),
              _buildInfoRow(Icons.person, 'Owner', workshop['ownerName']),
              _buildInfoRow(Icons.phone, 'Contact', workshop['phoneNo']),
              _buildInfoRow(Icons.car_repair, 'Vehicle Types',
                  workshop['vehicleTypes']?.join(', ')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(width: 8),
        Text('$label: ${value ?? 'N/A'}',
            style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

class RequestDialog extends StatefulWidget {
  final QueryDocumentSnapshot workshop;

  RequestDialog({required this.workshop});

  @override
  _RequestDialogState createState() => _RequestDialogState();
}

class _RequestDialogState extends State<RequestDialog> {
  TextEditingController descriptionController = TextEditingController();
  String? userUid = FirebaseAuth.instance.currentUser?.uid;

  void sendRequest() {
    if (userUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to send a request.')),
      );
      return;
    }

    FirebaseFirestore.instance.collection('request').add({
      'workshopId': widget.workshop.id,
      'companyName': widget.workshop['companyName'],
      'description': descriptionController.text,
      'userId': userUid,
      'timestamp': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Request sent successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Request to ${widget.workshop['companyName']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter details about the repair or issue',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: sendRequest,
            child: Text('Send Request'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            ),
          ),
        ],
      ),
    );
  }
}
