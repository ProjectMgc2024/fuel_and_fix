import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PaymentScreen(
        workshop: {
          'id': 'owner123',
          'companyName': 'XYZ Machinery'
        }, // Example data
        userid: 'user123', // Example user UID
      ),
    ),
  );
}

class PaymentScreen extends StatefulWidget {
  final Map<String, dynamic> workshop;
  // ignore: prefer_typing_uninitialized_variables
  final userid;

  PaymentScreen({required this.workshop, required this.userid, String? userId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _openCheckout(double amount) async {
    var options = {
      'key': 'rzp_test_QLvdqmBfoYL2Eu',
      'amount': (amount * 100).toInt(),
      'name': 'Machinery Booking',
      'description': 'Payment for machinery rental',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment successful: ${response.paymentId}')),
    );

    // Add request to Firestore
    FirebaseFirestore.instance.collection('request').add({
      'ownerId': widget.workshop['id'],
      'companyName': widget.workshop['companyName'],
      'description': _descriptionController.text,
      'userId': widget.userid,
      'timestamp': FieldValue.serverTimestamp(),
    }).then((_) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Request sent successfully!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send request: $error')),
      );
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Failed: ${response.code} - ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Amount',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _descriptionController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                labelText: 'Enter Description',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  final amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    _openCheckout(amount);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid amount')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Amount cannot be empty')),
                  );
                }
              },
              child: Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}
