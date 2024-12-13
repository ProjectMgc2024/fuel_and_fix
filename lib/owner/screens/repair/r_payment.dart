import 'package:flutter/material.dart';

class RPaymentsAndEarningsPage extends StatefulWidget {
  @override
  _PaymentsAndEarningsPageState createState() =>
      _PaymentsAndEarningsPageState();
}

class _PaymentsAndEarningsPageState extends State<RPaymentsAndEarningsPage> {
  // Mock data for earnings and payments related to repair services
  double totalEarnings = 5000.0;
  double pendingPayments = 1000.0;

  // Payment history for Repair Service with registration numbers
  final paymentHistory = [
    {
      'registrationNumber': 'KL45AJ7865',
      'date': '2024-11-01',
      'amount': '1000 Rs',
      'status': 'Paid'
    },
    {
      'registrationNumber': 'KL45AJ7866',
      'date': '2024-11-05',
      'amount': '1500 Rs',
      'status': 'Pending'
    },
    {
      'registrationNumber': 'KL45AJ7867',
      'date': '2024-11-10',
      'amount': '1500 Rs',
      'status': 'Failed'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Repair Service Payments & Earnings'),
          backgroundColor: Colors.teal),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildSummary(
                'Total Earnings from Repair Service:', '$totalEarnings Rs'),
            SizedBox(height: 20),
            _buildSummary(
                'Pending Payments for Repair Services:', '$pendingPayments Rs'),
            SizedBox(height: 20),
            Text('Repair Service Payment History:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...paymentHistory.map((payment) => _buildPaymentCard(payment)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(String title, String amount) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text(amount, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, String> payment) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Registration Number: ${payment['registrationNumber']}',
                style: TextStyle(fontSize: 14, color: Colors.blue)),
            Text('Date: ${payment['date']}',
                style: TextStyle(fontSize: 14, color: Colors.black45)),
            Text('Amount: ${payment['amount']}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Status: ${payment['status']}',
                style: TextStyle(
                    fontSize: 14,
                    color: payment['status'] == 'Paid'
                        ? Colors.green
                        : payment['status'] == 'Pending'
                            ? Colors.orange
                            : Colors.red)),
          ],
        ),
      ),
    );
  }
}
