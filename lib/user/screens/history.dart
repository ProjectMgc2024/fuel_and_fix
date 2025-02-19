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

  // Returns the UID of the currently logged-in user.
  String? getCurrentUserId() {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  // Formats a Firestore Timestamp into a readable string with timezone info.
  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    // Format like "30 December 2024 at 21:13:56 UTC+5:30"
    return DateFormat("d MMMM yyyy 'at' HH:mm:ss").format(dateTime) +
        " UTC+5:30";
  }

  @override
  Widget build(BuildContext context) {
    String? currentUserId = getCurrentUserId();

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Order History'),
          backgroundColor: const Color.fromARGB(255, 150, 102, 68),
        ),
        body: Center(child: Text('Please log in to view your orders.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order History',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 141, 94, 32),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users
            .doc(currentUserId)
            .collection('orders')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return Center(
              child: Text('No orders found.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            );

          var orders = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              // Get the service type to determine which builder to call.
              var service = order['service'];
              var time = order['time'] as Timestamp?;

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

  // Builder for Fuel orders.
  Widget buildFuelCard(QueryDocumentSnapshot order, Timestamp? time) {
    final Map<String, dynamic> data = order.data() as Map<String, dynamic>;
    final String description =
        data['description'] ?? "No description available";
    final String ownerId = data['ownerId'] ?? "Unknown Owner";
    // For fuel orders, use 'paymentAmount' if available; otherwise, use 'totalAmount'
    final dynamic amountValue = data.containsKey('paymentAmount')
        ? data['paymentAmount']
        : data['totalAmount'];
    final String paymentAmount =
        amountValue != null ? amountValue.toString() : "0";
    final String paymentId = data['paymentId'] ?? "N/A";
    final String service = data['service'] ?? "fuel";

    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("description",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$description", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("ownerId",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$ownerId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("paymentAmount",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$paymentAmount", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("paymentId",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$paymentId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("service",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$service", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("time",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("${time != null ? formatTimestamp(time) : 'N/A'}",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Builder for Repair orders.
  Widget buildRepairCard(QueryDocumentSnapshot order, Timestamp? time) {
    final Map<String, dynamic> data = order.data() as Map<String, dynamic>;
    final String description =
        data['description'] ?? "No description available";
    final String ownerId = data['ownerId'] ?? "Unknown Owner";
    final dynamic amountValue = data['paymentAmount'];
    final String paymentAmount =
        amountValue != null ? amountValue.toString() : "0";
    final String paymentId = data['paymentId'] ?? "N/A";
    final String service = data['service'] ?? "repair";

    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("description",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$description", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("ownerId",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$ownerId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("paymentAmount",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$paymentAmount", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("paymentId",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$paymentId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("service",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$service", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("time",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("${time != null ? formatTimestamp(time) : 'N/A'}",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  // Builder for Tow orders.
  Widget buildTowCard(QueryDocumentSnapshot order, Timestamp? time) {
    final Map<String, dynamic> data = order.data() as Map<String, dynamic>;
    final String description =
        data['description'] ?? "No description available";
    final String ownerId = data['ownerId'] ?? "Unknown Owner";
    final dynamic amountValue = data['paymentAmount'];
    final String paymentAmount =
        amountValue != null ? amountValue.toString() : "0";
    final String paymentId = data['paymentId'] ?? "N/A";
    final String service = data['service'] ?? "tow";

    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("description",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$description", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("ownerId",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$ownerId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("paymentAmount",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$paymentAmount", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("paymentId",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$paymentId", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("service",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("$service", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text("time",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text("${time != null ? formatTimestamp(time) : 'N/A'}",
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
