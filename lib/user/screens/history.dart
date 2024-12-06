import 'package:flutter/material.dart';

// Simulating a service history model (this could come from an API in a real app)
class ServiceHistory {
  final String serviceName;
  final String location;
  final String date;
  final String
      status; // New field to track service status (e.g., "Completed", "Pending")
  final String orderId; // Unique order ID
  final String registrationNumber; // Vehicle registration number

  ServiceHistory({
    required this.serviceName,
    required this.location,
    required this.date,
    required this.status,
    required this.orderId,
    required this.registrationNumber,
  });
}

// Simulating an API call to fetch user history
Future<List<ServiceHistory>> fetchUserHistory() async {
  await Future.delayed(Duration(seconds: 2)); // Simulating network delay

  // Simulated user history data
  return [
    ServiceHistory(
        serviceName: 'Fuel Delivery',
        location: 'Location A',
        date: '2024-10-10',
        status: 'Completed',
        orderId: 'ORD001',
        registrationNumber: 'AB123CD'),
    ServiceHistory(
        serviceName: 'Battery Jump-Start',
        location: 'Location B',
        date: '2024-10-12',
        status: 'Completed',
        orderId: 'ORD002',
        registrationNumber: 'XY456ZT'),
    ServiceHistory(
        serviceName: 'Flat Tire Repair',
        location: 'Location C',
        date: '2024-11-01',
        status: 'Pending',
        orderId: 'ORD003',
        registrationNumber: 'LM789OP'),
    ServiceHistory(
        serviceName: 'Towing Service',
        location: 'Location D',
        date: '2024-11-15',
        status: 'Cancelled',
        orderId: 'ORD004',
        registrationNumber: 'JK234QR'),
    ServiceHistory(
        serviceName: 'Fuel Delivery',
        location: 'Location E',
        date: '2024-11-18',
        status: 'Pending',
        orderId: 'ORD005',
        registrationNumber: 'GH567KL'),
  ];
}

class UserHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User History'),
        backgroundColor: Color.fromARGB(255, 174, 177, 138),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.grey[100], // Light background color
        child: FutureBuilder<List<ServiceHistory>>(
          future: fetchUserHistory(), // Fetch user history data
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No service history available.'));
            }

            List<ServiceHistory> history = snapshot.data!;

            List<ServiceHistory> completed =
                history.where((s) => s.status == 'Completed').toList();
            List<ServiceHistory> pending =
                history.where((s) => s.status == 'Pending').toList();
            List<ServiceHistory> cancelled =
                history.where((s) => s.status == 'Cancelled').toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHistorySection('Completed History', completed),
                  _buildHistorySection('Pending History', pending),
                  _buildHistorySection('Cancelled History', cancelled),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHistorySection(String title, List<ServiceHistory> history) {
    if (history.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final service = history[index];
            return GestureDetector(
              onTap: () {
                // Implement action when a history item is tapped, if needed
              },
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: _getCardColor(service.status),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      _getStatusIcon(service.status),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.serviceName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Location: ${service.location}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            Text(
                              'Date: ${service.date}',
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.black54),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Reg. No: ${service.registrationNumber}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                      if (service.status == 'Pending')
                        _cancelButton(context, service.orderId),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Helper function to return status icons based on service status
  Widget _getStatusIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'Completed':
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case 'Pending':
        icon = Icons.access_time;
        color = Colors.orange;
        break;
      case 'Cancelled':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.help;
        color = Colors.grey;
    }

    return Icon(icon, color: color, size: 30);
  }

  // Helper function to return background color for each card based on status
  Color _getCardColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green[50]!;
      case 'Pending':
        return Colors.orange[50]!;
      case 'Cancelled':
        return Colors.red[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  // Cancel button for Pending orders
  Widget _cancelButton(BuildContext context, String orderId) {
    return ElevatedButton(
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order $orderId has been cancelled')),
        );
      },
      child: const Text('Cancel Order'),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: UserHistory(), // Updated home to the UserHistoryPage
  ));
}
