import 'package:flutter/material.dart';

class TransactionManagementPage extends StatefulWidget {
  @override
  _TransactionManagementPageState createState() =>
      _TransactionManagementPageState();
}

class _TransactionManagementPageState extends State<TransactionManagementPage> {
  List<Map<String, String>> transactions = [
    {
      'vehicleRegNo': 'KL12AB1234', // Unique vehicle registration number
      'amount': '100',
      'status': 'Completed',
      'customer': 'John Doe',
      'paymentMethod': 'GPay',
      'date': '2024-11-01'
    },
    {
      'vehicleRegNo':
          'KL12CD5678', // Another unique vehicle registration number
      'amount': '200',
      'status': 'Pending',
      'customer': 'Jane Smith',
      'paymentMethod': 'Paytm',
      'date': '2024-11-02'
    },
    {
      'vehicleRegNo': 'KL12XY6789',
      'amount': '150',
      'status': 'Failed',
      'customer': 'Chris Lee',
      'paymentMethod': 'PayPal',
      'date': '2024-11-03'
    },
    {
      'vehicleRegNo': 'KL12EF4321',
      'amount': '250',
      'status': 'Completed',
      'customer': 'Emily Clark',
      'paymentMethod': 'Paytm',
      'date': '2024-11-05'
    },
    {
      'vehicleRegNo': 'KL12GH5678',
      'amount': '300',
      'status': 'Pending',
      'customer': 'Michael Brown',
      'paymentMethod': 'GPay',
      'date': '2024-11-07'
    },
    {
      'vehicleRegNo': 'KL12IJ9012',
      'amount': '450',
      'status': 'Completed',
      'customer': 'Linda White',
      'paymentMethod': 'PayPal',
      'date': '2024-11-09'
    },
    // Added Bank Transfer and Other transactions
    {
      'vehicleRegNo': 'KL12KL3456',
      'amount': '500',
      'status': 'Completed',
      'customer': 'Rahul Verma',
      'paymentMethod': 'PhonePe',
      'date': '2024-11-10'
    },
    {
      'vehicleRegNo': 'KL12MN7890',
      'amount': '120',
      'status': 'Pending',
      'customer': 'Priya Rao',
      'paymentMethod': 'PhonePe',
      'date': '2024-11-12'
    },
    {
      'vehicleRegNo': 'KL12OP1234',
      'amount': '350',
      'status': 'Completed',
      'customer': 'Alice Cooper',
      'paymentMethod': 'Bank Transfer',
      'date': '2024-11-13'
    },
    {
      'vehicleRegNo': 'KL12QR5678',
      'amount': '200',
      'status': 'Completed',
      'customer': 'George Lucas',
      'paymentMethod': 'Other',
      'date': '2024-11-15'
    },
  ];

  String selectedPaymentMethod = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transaction & Payment Management'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSummary(),
            SizedBox(height: 20),
            _buildPaymentMethodFilter(),
            SizedBox(height: 20),
            Expanded(child: _buildTransactionList()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary() {
    int completed =
        transactions.where((t) => t['status'] == 'Completed').length;
    int pending = transactions.where((t) => t['status'] == 'Pending').length;
    int failed = transactions.where((t) => t['status'] == 'Failed').length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Completed: $completed'),
        Text('Pending: $pending'),
        Text('Failed: $failed'),
      ],
    );
  }

  Widget _buildPaymentMethodFilter() {
    return Row(
      children: [
        Text('Filter by Payment Method: '),
        DropdownButton<String>(
          value: selectedPaymentMethod,
          onChanged: (String? newValue) {
            setState(() {
              selectedPaymentMethod = newValue!;
            });
          },
          items: <String>[
            'All',
            'GPay',
            'Paytm',
            'PayPal',
            'PhonePe',
            'Bank Transfer',
            'Other'
          ].map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTransactionList() {
    var filteredTransactions = transactions;

    // Apply payment method filter
    if (selectedPaymentMethod != 'All') {
      filteredTransactions = filteredTransactions
          .where((t) => t['paymentMethod'] == selectedPaymentMethod)
          .toList();
    }

    return ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        var transaction = filteredTransactions[index];
        return _buildTransactionCard(transaction, index);
      },
    );
  }

  Widget _buildTransactionCard(Map<String, String> transaction, int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Transaction details on the left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      'Vehicle Reg No: ${transaction['vehicleRegNo']} - Amount: \$${transaction['amount']}'),
                  Text('Customer: ${transaction['customer']}'),
                  Text('Payment: ${transaction['paymentMethod']}'),
                ],
              ),
            ),
            // Delete button on the right
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteTransaction(index),
            ),
          ],
        ),
        subtitle: _buildStatusTag(transaction['status']!),
        onTap: () => _viewTransactionDetails(transaction),
      ),
    );
  }

  Widget _buildStatusTag(String status) {
    Color color = Colors.grey;
    if (status == 'Completed') color = Colors.green;
    if (status == 'Pending') color = Colors.orange;
    if (status == 'Failed') color = Colors.red;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(status, style: TextStyle(color: Colors.white)),
    );
  }

  void _viewTransactionDetails(Map<String, String> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vehicle Reg No: ${transaction['vehicleRegNo']}'),
            Text('Amount: \$${transaction['amount']}'),
            Text('Customer: ${transaction['customer']}'),
            Text('Payment Method: ${transaction['paymentMethod']}'),
            Text('Status: ${transaction['status']}'),
            Text('Date: ${transaction['date']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteTransaction(int index) {
    setState(() {
      transactions.removeAt(index);
    });
  }
}
