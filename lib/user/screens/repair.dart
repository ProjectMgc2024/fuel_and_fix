import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  late Razorpay _razorpay;
  String? userUid = FirebaseAuth.instance.currentUser?.uid;
  String? selectedIssue;

  final List<String> issues = ["Puncture", "Breakdown", "Engine Failure"];

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _saveRequestToFirestore(
      isPayment: true,
      paymentId: response.paymentId,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful! Request sent.')),
    );
    Navigator.pop(context);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed. Please try again.')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('External wallet selected: ${response.walletName}')),
    );
  }

  void _initiatePayment() {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0', // Razorpay API key
      'amount': 600 * 100, // Amount in paise
      'currency': 'INR',
      'name': widget.workshop['companyName'],
      'description': 'Vehicle Repair Request',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@example.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  void _saveRequestToFirestore({required bool isPayment, String? paymentId}) {
    if (userUid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please log in to send a request.')),
      );
      return;
    }

    String ownerId = widget.workshop['ownerId'] ?? 'N/A';
    int paymentAmount = 600;
    String service = selectedIssue ?? 'Unknown';
    String time = DateTime.now().toLocal().toString();
    String description = descriptionController.text;

    FirebaseFirestore.instance
        .collection('user')
        .doc(userUid)
        .collection('orders')
        .add({
      'ownerId': ownerId,
      'paymentAmount': paymentAmount,
      'paymentId': paymentId,
      'service': service,
      'time': time,
      'description': description,
      'status': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance
        .collection('repair')
        .doc(widget.workshop.id)
        .collection('request')
        .add({
      'isPayment': isPayment,
      'description': description,
      'paymentId': paymentId,
      'status': true,
      'timestamp': FieldValue.serverTimestamp(),
      'userId': userUid,
      'issue': selectedIssue,
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Send Request to ${widget.workshop['companyName']}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Issue',
                border: OutlineInputBorder(),
              ),
              value: selectedIssue,
              items: issues
                  .map((issue) => DropdownMenuItem(
                        value: issue,
                        child: Text(issue),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedIssue = value;
                });
              },
            ),
            SizedBox(height: 20),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Enter details about the repair or issue',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _initiatePayment,
              child: Text('Pay & Send Request'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
