import 'package:flutter/material.dart';

class ReportsAnalyticsPage extends StatefulWidget {
  @override
  _ReportsAnalyticsPageState createState() => _ReportsAnalyticsPageState();
}

class _ReportsAnalyticsPageState extends State<ReportsAnalyticsPage> {
  // Sample transactions with unique vehicle registration numbers
  List<Map<String, String>> transactions = [
    {
      'vehicleRegistration': 'KA01AB1234', // Updated to vehicle registration
      'amount': '100',
      'status': 'Completed',
      'paymentMethod': 'GPay',
      'date': '2024-11-01'
    },
    {
      'vehicleRegistration': 'KA02CD5678',
      'amount': '200',
      'status': 'Pending',
      'paymentMethod': 'Paytm',
      'date': '2024-11-02'
    },
    {
      'vehicleRegistration': 'KA03EF9101',
      'amount': '150',
      'status': 'Failed',
      'paymentMethod': 'PayPal',
      'date': '2024-11-03'
    },
    {
      'vehicleRegistration': 'KA04GH1122',
      'amount': '250',
      'status': 'Completed',
      'paymentMethod': 'Paytm',
      'date': '2024-11-05'
    },
    {
      'vehicleRegistration': 'KA05IJ3344',
      'amount': '300',
      'status': 'Pending',
      'paymentMethod': 'GPay',
      'date': '2024-11-07'
    },
    {
      'vehicleRegistration': 'KA06KL5566',
      'amount': '450',
      'status': 'Completed',
      'paymentMethod': 'PayPal',
      'date': '2024-11-09'
    },
    {
      'vehicleRegistration': 'KA07MN7788',
      'amount': '500',
      'status': 'Completed',
      'paymentMethod': 'PhonePe',
      'date': '2024-11-10'
    },
    {
      'vehicleRegistration': 'KA08OP9900',
      'amount': '120',
      'status': 'Pending',
      'paymentMethod': 'PhonePe',
      'date': '2024-11-12'
    },
    {
      'vehicleRegistration': 'KA09QR1234',
      'amount': '350',
      'status': 'Completed',
      'paymentMethod': 'Bank Transfer',
      'date': '2024-11-13'
    },
    {
      'vehicleRegistration': 'KA10ST5678',
      'amount': '200',
      'status': 'Completed',
      'paymentMethod': 'Other',
      'date': '2024-11-15'
    },
  ];

  double totalRevenue = 0;
  Map<String, int> statusCounts = {};

  @override
  void initState() {
    super.initState();
    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    totalRevenue = 0;
    statusCounts = {'Completed': 0, 'Pending': 0, 'Failed': 0};

    for (var transaction in transactions) {
      double amount = double.tryParse(transaction['amount'] ?? '0') ?? 0.0;
      totalRevenue += amount;

      statusCounts[transaction['status']!] =
          (statusCounts[transaction['status']!] ?? 0) + 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reports & Analytics'),
        backgroundColor: Colors.blueGrey,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(),
            SizedBox(height: 20),
            _buildStatusBreakdown(),
            SizedBox(height: 20),
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  // Simplified summary: Total Revenue and Transaction Count
  Widget _buildSummary() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total Revenue: \$${totalRevenue.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          SizedBox(height: 8),
          Text('Total Transactions: ${transactions.length}',
              style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }

  // Status Breakdown
  Widget _buildStatusBreakdown() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transactions by Status:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          SizedBox(height: 10),
          for (var status in statusCounts.keys)
            Card(
              margin: EdgeInsets.symmetric(vertical: 8),
              color: _getStatusColor(status),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$status',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                    Text('${statusCounts[status]}',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Simplified color selection for status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Failed':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  // Transaction List
  Widget _buildTransactionList() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Transactions List:',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey)),
          SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              var transaction = transactions[index];
              return InkWell(
                onTap: () {
                  // Navigate to transaction detail page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          TransactionDetailPage(transaction: transaction),
                    ),
                  );
                },
                child: Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Vehicle Registration: ${transaction['vehicleRegistration']}',
                                style: TextStyle(fontSize: 14)),
                            SizedBox(height: 5),
                            Text('Date: ${transaction['date']}',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Text('\$${transaction['amount']}',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('${transaction['status']}',
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class TransactionDetailPage extends StatelessWidget {
  final Map<String, String> transaction;

  TransactionDetailPage({required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Transaction Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Registration: ${transaction['vehicleRegistration']}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Amount: \$${transaction['amount']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Status: ${transaction['status']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Payment Method: ${transaction['paymentMethod']}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Date: ${transaction['date']}',
                style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
