import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VehicleRepairCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Repair Services'),
        centerTitle: true,
        elevation: 10,
        backgroundColor: const Color.fromARGB(255, 232, 145, 47),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Expanded(
              child:
                  WorkshopListScreen(), // Automatically show all active workshops
            ),
          ],
        ),
      ),
    );
  }
}

class WorkshopListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Fetch workshops where status is true (no location filter)
      stream: FirebaseFirestore.instance
          .collection('repair')
          .where('status', isEqualTo: true) // Filter by status = true
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

            return GestureDetector(
              onTap: () {
                // Show dialog on tap
                showDialog(
                  context: context,
                  builder: (context) => RequestDialog(workshop: workshop),
                );
              },
              child: Card(
                margin: EdgeInsets.all(12),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop['companyName'] ?? 'No Name',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Owner: ${workshop['ownerName'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text('Contact: ${workshop['phoneNo'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text(
                        'Vehicle Types: ${workshop['vehicleTypes']?.join(', ') ?? 'N/A'}',
                      ),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
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
      // If the user is not authenticated, show a message and return
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to send a request.')),
      );
      return;
    }

    // Send the request to Firestore or other backend
    FirebaseFirestore.instance.collection('request').add({
      'workshopId': widget.workshop.id, // Workshop ID
      'companyName': widget.workshop['companyName'], // Workshop company name
      'description': descriptionController.text, // User-provided description
      'userId': userUid, // Store the user ID who is making the request
      'timestamp': FieldValue
          .serverTimestamp(), // Timestamp for when the request was made
    });

    Navigator.pop(context); // Close the dialog after sending the request
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
          Text('Provide a description of the issue or request:'),
          SizedBox(height: 8),
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
              backgroundColor:
                  Color.fromARGB(255, 232, 145, 47), // Button color
            ),
          ),
        ],
      ),
    );
  }
}
