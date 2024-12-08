import 'package:flutter/material.dart';

class PaymentsAndEarningsPage extends StatefulWidget {
  @override
  _PaymentsAndEarningsPageState createState() =>
      _PaymentsAndEarningsPageState();
}

class _PaymentsAndEarningsPageState extends State<PaymentsAndEarningsPage> {
  // Mock data for earnings and payments
  double totalEarnings = 5000.0;
  double pendingPayments = 1000.0;

  // Payment history
  List<Map<String, String>> paymentHistory = [
    {
      'registrationNumber': 'KL45AJ7865',
      'date': '2024-11-01',
      'serviceType': 'Fuel Delivery',
      'amount': '1000 Rs',
      'status': 'Paid',
      'paymentMethod': 'Bank Transfer'
    },
    {
      'registrationNumber': 'KL45AJ7866',
      'date': '2024-11-05',
      'serviceType': 'Maintenance',
      'amount': '1500 Rs',
      'status': 'Pending',
      'paymentMethod': 'PayPal'
    },
    {
      'registrationNumber': 'KL45AJ7867',
      'date': '2024-11-10',
      'serviceType': 'Fuel Delivery',
      'amount': '1500 Rs',
      'status': 'Failed',
      'paymentMethod': 'Credit Card'
    },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter only Fuel Delivery payments
    var fuelPayments = paymentHistory
        .where((payment) => payment['serviceType'] == 'Fuel Delivery')
        .toList();

    return Scaffold(
      appBar: AppBar(
          title: Text('Payments & Earnings'), backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Earnings Summary
            _buildSummary('Total Earnings:', '$totalEarnings Rs'),
            SizedBox(height: 20),
            _buildSummary('Pending Payments:', '$pendingPayments Rs',
                color: Colors.orange),
            SizedBox(height: 20),
            // Payment History Section
            Text('Fuel Delivery Payment History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            ...fuelPayments.map((payment) => _buildPaymentCard(payment)),
          ],
        ),
      ),
    );
  }

  // Summary section widget
  Widget _buildSummary(String title, String amount,
      {Color color = Colors.black}) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(amount, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }

  // Payment card widget
  Widget _buildPaymentCard(Map<String, String> payment) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Registration Number
            Text('Registration Number: ${payment['registrationNumber']}',
                style: TextStyle(fontSize: 14, color: Colors.blue)),
            Text('Date: ${payment['date']}',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
            // Service Type
            Text('Service: ${payment['serviceType']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // Amount
            Text('Amount: ${payment['amount']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            // Payment Method
            Text('Payment Method: ${payment['paymentMethod']}',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
            // Status with color
            Text(
              'Status: ${payment['status']}',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get status color based on payment status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
