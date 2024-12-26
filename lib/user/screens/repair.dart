import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopScreen extends StatefulWidget {
  @override
  _WorkshopScreenState createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;

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

  Future<List<Map<String, dynamic>>> _getWorkshops() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('repair')
        .where('status', isEqualTo: true)
        .get();

    List<Map<String, dynamic>> workshops = [];
    for (var doc in querySnapshot.docs) {
      workshops.add({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    }
    return workshops;
  }

  Future<void> _openGoogleMaps(
      {required double latitude, required double longitude}) async {
    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (await canLaunch(googleMapsUri.toString())) {
      await launch(googleMapsUri.toString());
    } else {
      throw "Could not launch Google Maps";
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore.collection('user').doc(user.uid).collection('orders').add({
      'ownerId': user.uid,
      'paymentAmount': 500,
      'paymentId': response.paymentId,
      'service': 'repair',
      'time': DateTime.now(),
      'description': 'Repair service payment',
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Successful!")),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  void _payWithRazorpay(String userId) {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': 250, // Amount in paise (500.00 INR)
      'name': 'Repair Service',
      'description': 'Repair service payment',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workshops')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getWorkshops(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No active workshops available.'));
          } else {
            List<Map<String, dynamic>> workshops = snapshot.data!;

            return ListView.builder(
              itemCount: workshops.length,
              itemBuilder: (context, index) {
                var workshop = workshops[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                    leading: Image.network(workshop['companyLogo']),
                    title: Text(workshop['companyName']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Location: ${workshop['location_name'] ?? 'Not Available'}'),
                        Text('Phone: ${workshop['phoneNo']}'),
                        Text('Service: ${workshop['service']}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.location_on),
                          onPressed: () => _openGoogleMaps(
                            latitude: workshop['latitude'],
                            longitude: workshop['longitude'],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.payment),
                          onPressed: () => _payWithRazorpay(
                            FirebaseAuth.instance.currentUser!.uid,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.feedback),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FeedbackScreen(
                                  stationId: workshop['id'],
                                  stationName: workshop['companyName'],
                                  service: 'repair',
                                  userId:
                                      FirebaseAuth.instance.currentUser?.uid,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
