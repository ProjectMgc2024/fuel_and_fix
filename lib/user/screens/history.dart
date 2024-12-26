import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importing the intl package

class OrderHistoryPage extends StatefulWidget {
  @override
  _OrderHistoryPageState createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  late CollectionReference users;

  @override
  void initState() {
    super.initState();
    users = FirebaseFirestore.instance.collection('user');
  }

  Future<Map<String, dynamic>> getServiceDetails(String service) async {
    var serviceDoc =
        await FirebaseFirestore.instance.collection(service).doc(service).get();
    return serviceDoc.exists
        ? {
            'paymentAmount': serviceDoc['paymentAmount'] ?? 0,
            'paymentId': serviceDoc['paymentId'] ?? 'N/A',
            'time': serviceDoc['time'] ?? 'N/A',
            'description':
                serviceDoc['description'] ?? 'No description available'
          }
        : {
            'paymentAmount': 0,
            'paymentId': 'N/A',
            'time': 'N/A',
            'description': 'No description available'
          };
  }

  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Function to format the timestamp
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy \'at\' HH:mm:ss z').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = getCurrentUserId();

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order History'),
          backgroundColor: const Color.fromARGB(255, 0, 36, 99),
        ),
        body: Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Order History',
            style: TextStyle(fontSize: 24, color: Colors.white)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 205, 118, 4),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: users.doc(currentUserId).collection('orders').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
                child: Text('No orders found.',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w500)));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var fuelType = order['fuelType'];
              var litres = order['litres'];
              var paymentAmount = order['paymentAmount'];
              var service = order['service'];
              var time = order['time']; // Firestore timestamp
              var ownerId = order['ownerId']; // Fetch the ownerId field
              var companyName = order['companyName']; // Fetch the company name

              return Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            service == 'fuel'
                                ? Icons.local_gas_station
                                : Icons.settings,
                            color: service == 'fuel'
                                ? Colors.orange
                                : Colors.blueAccent,
                            size: 32,
                          ),
                          SizedBox(width: 12),
                          Text(
                            service.toUpperCase(),
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color.fromARGB(255, 192, 106, 1)),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      if (service == 'fuel') ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Company Name: ${companyName ?? 'N/A'}', // Display companyName
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text('Fuel Type: $fuelType',
                                style: TextStyle(fontSize: 16)),
                            Text('Litres: $litres',
                                style: TextStyle(fontSize: 16)),
                            Text('Payment: ₹$paymentAmount',
                                style: TextStyle(fontSize: 16)),
                            Text(
                                'Time: ${time != null ? formatTimestamp(time) : 'N/A'}', // Format the time
                                style: TextStyle(fontSize: 16)),
                            Text(
                                'OwnerId: ${ownerId ?? 'N/A'}', // Display ownerId
                                style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ] else ...[
                        FutureBuilder<Map<String, dynamic>>(
                          future: getServiceDetails(service),
                          builder: (context, serviceSnapshot) {
                            if (serviceSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            var serviceDetails = serviceSnapshot.data ?? {};

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Company Name: ${companyName ?? 'N/A'}',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    'Payment Amount: ₹${serviceDetails['paymentAmount']}',
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    'PaymentId: ${serviceDetails['paymentId']}',
                                    style: TextStyle(fontSize: 16)),
                                Text('Time: ${serviceDetails['time']}',
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    'Description: ${serviceDetails['description']}',
                                    style: TextStyle(fontSize: 16)),
                                Text(
                                    'OwnerId: ${ownerId ?? 'N/A'}', // Display ownerId
                                    style: TextStyle(fontSize: 16)),
                              ],
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
