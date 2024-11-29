import 'package:flutter/material.dart';

class PaymentsAndEarningsPage extends StatefulWidget {
  @override
  _PaymentsAndEarningsPageState createState() =>
      _PaymentsAndEarningsPageState();
}

class _PaymentsAndEarningsPageState extends State<PaymentsAndEarningsPage> {
  // Mock data for earnings and payments
  double totalEarnings = 5000.0;
  double platformCommission = 0.15; // 15% platform commission
  double taxRate = 0.1; // 10% tax rate
  double pendingPayments = 1000.0;
  double bonus = 300.0;
  double totalAvailableBalance = 4000.0;

  // Payment history from users, now with registration numbers as unique user IDs
  List<Map<String, String>> paymentHistory = [
    {
      'registrationNumber': 'KL45AJ7865', // Registration number (Unique ID)
      'date': '2024-11-01',
      'serviceType': 'Fuel Delivery',
      'amount': '1000 Rs',
      'status': 'Paid',
      'paymentMethod': 'Bank Transfer',
    },
    {
      'registrationNumber': 'KL45AJ7866', // Registration number (Unique ID)
      'date': '2024-11-05',
      'serviceType': 'Maintenance',
      'amount': '1500 Rs',
      'status': 'Pending',
      'paymentMethod': 'PayPal',
    },
    {
      'registrationNumber': 'KL45AJ7867', // Registration number (Unique ID)
      'date': '2024-11-10',
      'serviceType': 'Fuel Delivery',
      'amount': '1500 Rs',
      'status': 'Failed',
      'paymentMethod': 'Credit Card',
    },
  ];

  // Withdrawal amount controller
  TextEditingController withdrawalController = TextEditingController();

  // Calculate commission and tax deductions
  double getCommission(double earnings) {
    return earnings * platformCommission;
  }

  double getTaxDeduction(double earnings) {
    return earnings * taxRate;
  }

  double getNetEarnings(double earnings) {
    return earnings - getCommission(earnings) - getTaxDeduction(earnings);
  }

  // Handle withdrawal request
  void handleWithdrawal() {
    double requestedAmount = double.tryParse(withdrawalController.text) ?? 0.0;

    if (requestedAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid withdrawal amount.'),
      ));
      return;
    }

    if (requestedAmount > totalAvailableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Insufficient balance for withdrawal.'),
      ));
      return;
    }

    setState(() {
      totalAvailableBalance -= requestedAmount;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Withdrawal of $requestedAmount Rs successful!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    double netEarnings = getNetEarnings(totalEarnings);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payments & Earnings'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Earnings Summary
            Text(
              'Earnings Summary:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Total Earnings: $totalEarnings Rs',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              'Platform Commission (15%): ${getCommission(totalEarnings)} Rs',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            Text(
              'Tax Deduction (10%): ${getTaxDeduction(totalEarnings)} Rs',
              style: TextStyle(fontSize: 16, color: Colors.red),
            ),
            Text(
              'Net Earnings After Deduction: $netEarnings Rs',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Bonus: $bonus Rs',
              style: TextStyle(fontSize: 16, color: Colors.green),
            ),
            SizedBox(height: 20),

            // Pending Payments Section
            Text(
              'Pending Payments: $pendingPayments Rs',
              style: TextStyle(fontSize: 16, color: Colors.orange),
            ),
            SizedBox(height: 20),

            // Payment History Section with Registration Number
            Text(
              'Payment History:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              itemCount: paymentHistory.length,
              itemBuilder: (context, index) {
                var payment = paymentHistory[index];
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Registration Number (Unique ID)
                        Text(
                          'Registration Number: ${payment['registrationNumber']}',
                          style: TextStyle(fontSize: 14, color: Colors.blue),
                        ),
                        Text(
                          'Date: ${payment['date']}',
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                        Text(
                          'Service: ${payment['serviceType']}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Amount: ${payment['amount']}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Payment Method: ${payment['paymentMethod']}',
                          style: TextStyle(fontSize: 14, color: Colors.black45),
                        ),
                        Text(
                          'Status: ${payment['status']}',
                          style: TextStyle(
                            fontSize: 14,
                            color: payment['status'] == 'Paid'
                                ? Colors.green
                                : payment['status'] == 'Pending'
                                    ? Colors.orange
                                    : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            SizedBox(height: 20),

            // Withdrawal Section
            TextField(
              controller: withdrawalController,
              decoration: InputDecoration(
                labelText: 'Enter withdrawal amount',
                prefixIcon: Icon(Icons.money),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: handleWithdrawal,
              child: Text('Request Withdrawal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
