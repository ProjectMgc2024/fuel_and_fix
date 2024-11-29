import 'package:flutter/material.dart';

class EmergencyRepairRequest extends StatefulWidget {
  @override
  _EmergencyRepairRequestsPageState createState() =>
      _EmergencyRepairRequestsPageState();
}

class _EmergencyRepairRequestsPageState extends State<EmergencyRepairRequest> {
  final List<Map<String, dynamic>> requests = [
    {
      'customer': 'John Doe',
      'vehicle': 'Car - Toyota Corolla',
      'issue': 'Flat tire and engine issue',
      'location': '123 Main St',
      'status': 'Pending',
      'time': '12:45 PM',
    },
    {
      'customer': 'Sarah Connor',
      'vehicle': 'Bike - Honda CBR',
      'issue': 'Brake failure',
      'location': '456 Elm St',
      'status': 'In Progress',
      'time': '1:30 PM',
    },
    // Add more requests here...
  ];

  void _updateStatus(int index, String newStatus) {
    setState(() {
      requests[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Request marked as $newStatus'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _viewDetails(int index) {
    final request = requests[index];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Details'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Customer: ${request['customer']}'),
              Text('Vehicle: ${request['vehicle']}'),
              Text('Issue: ${request['issue']}'),
              Text('Location: ${request['location']}'),
              Text('Requested At: ${request['time']}'),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  // Add map navigation functionality here
                },
                icon: Icon(Icons.map),
                label: Text('View Location on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Repair Requests'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return Card(
                elevation: 8,
                margin: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        request['customer'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _statusChip(request['status']),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request['vehicle'],
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700])),
                      SizedBox(height: 4),
                      Text('Issue: ${request['issue']}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600])),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.blueGrey, size: 18),
                              SizedBox(width: 4),
                              Text(request['location'],
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700])),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _viewDetails(index),
                                child: Text('Details',
                                    style: TextStyle(color: Colors.blueGrey)),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'In Progress'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                ),
                                child: Text('Accept'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'Rejected'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text('Reject'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // Status Chip Widget
  Widget _statusChip(String status) {
    Color chipColor;
    switch (status) {
      case 'Pending':
        chipColor = Colors.orange;
        break;
      case 'In Progress':
        chipColor = Colors.blue;
        break;
      case 'Rejected':
        chipColor = Colors.red;
        break;
      case 'Completed':
        chipColor = Colors.green;
        break;
      default:
        chipColor = Colors.grey;
    }

    return Chip(
      label: Text(
        status,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: chipColor,
    );
  }
}
