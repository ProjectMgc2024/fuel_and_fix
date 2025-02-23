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
    return DateFormat("d MMMM yyyy 'at' hh:mm a").format(dateTime);
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
              var time = order['time'] as Timestamp?;
              return buildOrderCard(order, time);
            },
          );
        },
      ),
    );
  }

  Widget buildOrderCard(QueryDocumentSnapshot order, Timestamp? time) {
    final Map<String, dynamic> data = order.data() as Map<String, dynamic>;

    return Card(
      elevation: 8,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextRow("Service Type", data['service'] ?? "Unknown"),
            buildTextRow(
                "Company Name", data['companyName'] ?? "Unknown Company"),
            buildTextRow("Payment Amount", "Rs ${data['paymentAmount'] ?? 0}"),
            buildTextRow("Payment ID", data['paymentId'] ?? "N/A"),
            if (data['service'] == 'fuel' && data.containsKey('litres'))
              buildTextRow("Litres", "${data['litres']}"),
            buildTextRow(
              "Order Time",
              time != null ? formatTimestamp(time) : 'N/A',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextRow(String title, String value,
      {Color? color, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16, color: color ?? Colors.black),
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
            ),
          ),
        ],
      ),
    );
  }
}
