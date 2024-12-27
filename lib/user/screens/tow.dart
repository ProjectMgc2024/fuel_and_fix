import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuel_and_fix/owner/screens/feedbackview.dart';

class TowingServiceCategories extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Towing Services',
          style: TextStyle(color: const Color.fromARGB(255, 255, 252, 252)),
        ),
        centerTitle: true,
        elevation: 10,
        backgroundColor: Color.fromARGB(255, 83, 89, 162),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TowingCompanyListScreen(),
      ),
    );
  }
}

class TowingCompanyListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tow').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final towingCompanies = snapshot.data?.docs ?? [];

        if (towingCompanies.isEmpty) {
          return Center(child: Text('No towing services available.'));
        }

        return ListView.builder(
          itemCount: towingCompanies.length,
          itemBuilder: (context, index) {
            final company = towingCompanies[index];

            return TowingCompanyCard(company: company);
          },
        );
      },
    );
  }
}

class TowingCompanyCard extends StatelessWidget {
  final QueryDocumentSnapshot company;

  TowingCompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => RequestDialog(company: company),
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 147, 193, 214),
        margin: EdgeInsets.symmetric(vertical: 8),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              if (company['companyLogo'] != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    company['companyLogo'],
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        company['companyName'] ?? 'No Name',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    _buildInfoRow(Icons.phone, 'Contact', company['phoneNo']),
                    _buildInfoRow(Icons.email, 'Email', company['email']),
                    _buildServicesRow(company['additionalData']),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackScreen(
                                  
                                ),
                              ),
                            );
                          },
                          child: Text('Feedback'),
                        ),
                      ],
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

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, size: 16),
        SizedBox(width: 5),
        Text('$label: ${value ?? 'N/A'}',
            style: TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }

  Widget _buildServicesRow(Map<String, dynamic>? additionalData) {
    if (additionalData == null || additionalData.isEmpty) {
      return Text('No additional information available.',
          style: TextStyle(fontStyle: FontStyle.italic));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Additional Information:',
            style: TextStyle(fontWeight: FontWeight.bold)),
        Text('License: ${additionalData['companyLicense'] ?? 'N/A'}'),
        Text('Location: ${additionalData['location_name'] ?? 'N/A'}'),
      ],
    );
  }
}

class RequestDialog extends StatefulWidget {
  final QueryDocumentSnapshot company;

  RequestDialog({required this.company});

  @override
  _RequestDialogState createState() => _RequestDialogState();
}

class _RequestDialogState extends State<RequestDialog> {
  TextEditingController descriptionController = TextEditingController();
  String? userUid = FirebaseAuth.instance.currentUser?.uid;

  void sendRequest() async {
    if (userUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to send a request.')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('request').add({
        'ownerId': widget.company.id,
        'companyName': widget.company['companyName'],
        'description': descriptionController.text,
        'userId': userUid,
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error sending request: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Request to ${widget.company['companyName']}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter details about the towing request',
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
