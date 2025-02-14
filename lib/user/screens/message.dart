import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class UserNotificationPage extends StatefulWidget {
  @override
  _UserNotificationPageState createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  // Use the current user's UID; if not logged in, an empty string.
  final String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? "";
  late Razorpay _razorpay;

  // Temporary variables to store company info before payment.
  Map<String, dynamic>? _currentCompany;
  String? _currentCompanyId;
  String? _currentServiceType; // Expected to be "fuel", "tow", or "repair"

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

  // Fetch notifications for the current user.
  Stream<List<QueryDocumentSnapshot>> fetchNotifications() {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  // Fetch company details from one of the service collections (fuel, tow, repair).
  // If the document is from the repair collection and contains a field 'repairType',
  // we set serviceType to "repair". Otherwise, we simply set it to the collection name.
  Future<Map<String, dynamic>?> fetchCompanyDetails(String companyId) async {
    List<String> serviceCollections = ['fuel', 'tow', 'repair'];
    for (String collection in serviceCollections) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection(collection)
          .doc(companyId)
          .get();
      if (doc.exists) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          if (collection == 'repair' && data.containsKey('repairType')) {
            data['service'] = 'repair';
          } else {
            data['service'] = collection;
          }
        }
        return data;
      }
    }
    return null;
  }

  // Initiates the Razorpay payment process using the fetched company data.
  void _payWithRazorpay(Map<String, dynamic> companyData, String companyId) {
    _currentCompany = companyData;
    _currentCompanyId = companyId;
    _currentServiceType = companyData['service']; // "fuel", "tow", or "repair"

    String paymentName;
    String description;
    if (_currentServiceType == 'fuel') {
      paymentName = "Fuel Advance Payment";
      description = "Fuel purchase advance payment";
    } else if (_currentServiceType == 'tow') {
      paymentName = "Tow Advance Payment";
      description = "Tow service advance payment";
    } else if (_currentServiceType == 'repair') {
      paymentName = "Repair Advance Payment";
      description = "Repair service advance payment";
    } else {
      paymentName = "Advance Payment";
      description = "Service advance payment";
    }

    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': 20000, // Amount in paise (i.e., 200.00 INR)
      'name': paymentName,
      'description': description,
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

  // On successful payment, update the pending service request document and store the order
  // in the user's orders subcollection with the specified fields.
  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (_currentCompany == null ||
        _currentCompanyId == null ||
        _currentServiceType == null) return;

    // Select the correct collection based on service type.
    DocumentReference docRef;
    if (_currentServiceType == 'fuel') {
      docRef =
          FirebaseFirestore.instance.collection('fuel').doc(_currentCompanyId);
    } else if (_currentServiceType == 'tow') {
      docRef =
          FirebaseFirestore.instance.collection('tow').doc(_currentCompanyId);
    } else if (_currentServiceType == 'repair') {
      docRef = FirebaseFirestore.instance
          .collection('repair')
          .doc(_currentCompanyId);
    } else {
      return; // Unsupported service type.
    }

    // Query for the pending request (isPaid false) for this user.
    QuerySnapshot querySnapshot = await docRef
        .collection('request')
        .where('userId', isEqualTo: currentUserId)
        .where('isPaid', isEqualTo: false)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      DocumentReference requestDoc = querySnapshot.docs.first.reference;

      // Update the request document as paid.
      await requestDoc.update({
        'isPaid': true,
        'paymentId': response.paymentId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Retrieve the updated request data.
      Map<String, dynamic> requestData =
          (await requestDoc.get()).data() as Map<String, dynamic>;

      // Create order data with specific fields.
      Map<String, dynamic> orderData;
      if (_currentServiceType == 'repair') {
        // For repair service, store the fields as specified.
        orderData = {
          'description': "Repair service payment",
          'ownerId': "aVo34xBgfDbufDAza5rl8BuHRhf1",
          'paymentAmount': 500,
          'paymentId': response.paymentId,
          'service': "repair",
          'time': FieldValue.serverTimestamp(),
        };
      } else {
        // For other services, use the requestData and update common fields.
        orderData = {
          ...requestData,
          'paymentId': response.paymentId,
          'time': FieldValue.serverTimestamp(),
          'service': _currentServiceType,
        };
      }

      // Store the order in the user's orders subcollection.
      DocumentReference userOrderRef = FirebaseFirestore.instance
          .collection('user')
          .doc(currentUserId)
          .collection('orders')
          .doc();
      await userOrderRef.set(orderData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text("Payment Successful, Request Updated, and Order Saved!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No pending request found to update.")),
      );
    }

    _currentCompany = null;
    _currentCompanyId = null;
    _currentServiceType = null;
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

  // Displays a confirmation dialog before initiating the payment.
  void _showPaymentDialog(Map<String, dynamic> companyData, String companyId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Payment'),
          content: Text('Do you want to proceed with the advance payment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _payWithRazorpay(companyData, companyId);
              },
              child: Text('Proceed to Pay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Notifications'),
        backgroundColor: const Color.fromARGB(255, 180, 187, 126),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: fetchNotifications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No notifications found.'));
          }
          final notifications = snapshot.data!;
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notification =
                  notifications[index].data() as Map<String, dynamic>;
              String companyId = notification['companyId'] ?? '';
              String message =
                  notification['message'] ?? 'No message available';
              Timestamp? timestamp = notification['timestamp'] as Timestamp?;
              // Check the status from the notification.
              final String requestStatus =
                  (notification['status'] ?? '').toString().toLowerCase();
              // Only allow payment if the status is accepted.
              bool isAccepted = requestStatus == 'accepted';

              return FutureBuilder<Map<String, dynamic>?>(
                future: fetchCompanyDetails(companyId),
                builder: (context, companySnapshot) {
                  if (companySnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!companySnapshot.hasData ||
                      companySnapshot.data == null) {
                    return ListTile(
                        title: Text('Error fetching company details'));
                  }
                  var companyData = companySnapshot.data!;
                  String companyName =
                      companyData['companyName'] ?? 'Unknown Company';
                  String companyLogo = companyData['companyLogo'] ?? '';
                  String companyPhone = companyData['phoneNo'] ?? '';
                  String ownerName =
                      companyData['ownerName'] ?? 'Unknown Owner';
                  String service = companyData['service'] ?? '';
                  String formattedTimestamp = timestamp != null
                      ? timestamp.toDate().toLocal().toString()
                      : 'Unknown Timestamp';
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          companyLogo.isNotEmpty
                              ? Center(
                                  child: Image.network(
                                    companyLogo,
                                    height: 80,
                                    width: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : SizedBox(height: 80),
                          SizedBox(height: 16),
                          Text(
                            companyName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 72, 81, 60),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(message),
                          SizedBox(height: 8),
                          Text('Timestamp: $formattedTimestamp'),
                          SizedBox(height: 8),
                          Text('Owner Name: $ownerName'),
                          SizedBox(height: 8),
                          Text('Phone: $companyPhone'),
                          SizedBox(height: 8),
                          // Display the "Pay Advance" button only if the service type is fuel, tow, or repair.
                          // The button is enabled only if the notification status is accepted.
                          if (service == 'fuel' ||
                              service == 'tow' ||
                              service == 'repair')
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: isAccepted
                                    ? () {
                                        _showPaymentDialog(
                                            companyData, companyId);
                                      }
                                    : null,
                                child: Text('Pay Advance'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
