import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('d MMMM yyyy ' ' HH:mm:ss z').format(dateTime);
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
              var service = order['service'];
              var time = order['time'];

              if (service == 'fuel') {
                return buildFuelCard(order, time);
              } else if (service == 'repair') {
                return buildRepairCard(order, time);
              } else if (service == 'tow') {
                return buildTowCard(order, time);
              } else {
                return SizedBox.shrink();
              }
            },
          );
        },
      ),
    );
  }

  Widget buildFuelCard(QueryDocumentSnapshot order, Timestamp? time) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_gas_station,
                  color: Colors.orange,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'FUEL',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 192, 106, 1)),
                ),
              ],
            ),
            SizedBox(height: 18),
            Text('Fuel Type: ${order['fuelType']}',
                style: TextStyle(fontSize: 16)),
            Text('Litres: ${order['litres']}', style: TextStyle(fontSize: 16)),
            Text('Payment: ₹${order['paymentAmount']}',
                style: TextStyle(fontSize: 16)),
            Text('PaymentId: ${order['paymentId']}',
                style: TextStyle(fontSize: 16)),
            Text('Time: ${time != null ? formatTimestamp(time) : 'N/A'}',
                style: TextStyle(fontSize: 16)),
            Text('OwnerId: ${order['ownerId']}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget buildRepairCard(QueryDocumentSnapshot order, Timestamp? time) {
    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Colors.blueAccent,
                  size: 32,
                ),
                SizedBox(width: 12),
                Text(
                  'REPAIR',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 192, 106, 1)),
                ),
              ],
            ),
            SizedBox(height: 18),
            Text('Description: ${order['description']}',
                style: TextStyle(fontSize: 16)),
            Text('Payment: ₹${order['paymentAmount']}',
                style: TextStyle(fontSize: 16)),
            Text('PaymentId: ${order['paymentId']}',
                style: TextStyle(fontSize: 16)),
            Text('Time: ${time != null ? formatTimestamp(time) : 'N/A'}',
                style: TextStyle(fontSize: 16)),
            Text('OwnerId: ${order['ownerId']}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

Widget buildTowCard(QueryDocumentSnapshot order, Timestamp? time) {
  // Get current time
  String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  return Card(
    elevation: 8,
    margin: EdgeInsets.symmetric(vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.car_repair,
                color: const Color.fromARGB(255, 255, 68, 68),
                size: 32,
              ),
              SizedBox(width: 12),
              Text(
                'TOW',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 192, 106, 1)),
              ),
            ],
          ),
          SizedBox(height: 18),
          Text('Description: ${order['description']}',
              style: TextStyle(fontSize: 16)),
          Text('Payment: ₹${order['paymentAmount']}',
              style: TextStyle(fontSize: 16)),
          Text('PaymentId: ${order['paymentId']}',
              style: TextStyle(fontSize: 16)),
          Text('Time: $currentTime', // Display current time
              style: TextStyle(fontSize: 16)),
          Text('OwnerId : ${order['ownerId']}', style: TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
