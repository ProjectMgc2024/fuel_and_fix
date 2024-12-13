import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class TowRequest extends StatefulWidget {
  @override
  _TowRequestPageState createState() => _TowRequestPageState();
}

class _TowRequestPageState extends State<TowRequest> {
  final List<Map<String, dynamic>> requests = [
    {
      'customer': 'John Doe',
      'vehicle': 'Car - Toyota Corolla',
      'issue': 'Accident, needs towing',
      'location': 'Near Sree Padmanabhaswamy Temple, Thiruvananthapuram',
      'status': 'Pending',
      'time': '12:45 PM',
      'latitude': 8.5241, // Latitude for Thiruvananthapuram, Kerala
      'longitude': 76.9366, // Longitude for Thiruvananthapuram, Kerala
    },
    {
      'customer': 'Sarah Connor',
      'vehicle': 'Bike - Honda CBR',
      'issue': 'Breakdown, needs towing',
      'location': 'Kochi, Kerala',
      'status': 'In Progress',
      'time': '1:30 PM',
      'latitude': 9.9312, // Latitude for Kochi, Kerala
      'longitude': 76.2673, // Longitude for Kochi, Kerala
    },
    {
      'customer': 'Amit Sharma',
      'vehicle': 'Truck - Tata 407',
      'issue': 'Engine failure, requires towing',
      'location': 'Munnar, Kerala',
      'status': 'Pending',
      'time': '2:00 PM',
      'latitude': 10.0881, // Latitude for Munnar, Kerala
      'longitude': 77.0590, // Longitude for Munnar, Kerala
    },
    // Add more requests as needed
  ];

  // Fetch the address from coordinates using reverse geocoding
  Future<String> getAddressFromCoordinates(
      double latitude, double longitude) async {
    final apiKey =
        'YOUR_GOOGLE_API_KEY'; // Replace with your Google Maps API Key
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return 'No address found';
      }
    } else {
      throw Exception('Failed to fetch address');
    }
  }

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

  void _launchMapsUrl(double latitude, double longitude) async {
    final String googleUrl =
        'https://www.google.com/maps?q=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Could not open the map.")),
      );
    }
  }

  void _viewDetails(int index) async {
    final request = requests[index];
    final address = await getAddressFromCoordinates(
        request['latitude'], request['longitude']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Request Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${request['customer']}'),
                Text('Vehicle: ${request['vehicle']}'),
                Text('Issue: ${request['issue']}'),
                Text('Location: $address'), // Show the formatted address here
                Text('Requested At: ${request['time']}'),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    _launchMapsUrl(request['latitude'], request['longitude']);
                  },
                  icon: Icon(Icons.map),
                  label: Text('View Location on Map'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
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
        title: Text('Tow Requests'),
        backgroundColor: Colors.teal,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context); // This pops the current screen off the stack
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            // Wrap the whole body in a SingleChildScrollView
            child: Column(
              children: [
                for (int index = 0; index < requests.length; index++)
                  Card(
                    elevation: 6,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Customer and status row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  requests[index]['customer'],
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ),
                              _statusChip(requests[index]['status']),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Vehicle and issue information
                          Text(
                            'Vehicle: ${requests[index]['vehicle']}',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[700]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Issue: ${requests[index]['issue']}',
                            style: TextStyle(
                                fontSize: 14, color: Colors.grey[600]),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 8),
                          // Location and time row
                          Row(
                            children: [
                              Icon(Icons.location_on,
                                  color: Colors.blueGrey, size: 18),
                              SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  requests[index]['location'],
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey[700]),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Requested At: ${requests[index]['time']}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey[600]),
                          ),
                          SizedBox(height: 10),
                          // Action buttons for Accept, Reject, and Details
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'In Progress'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green),
                                child: Text('Accept'),
                              ),
                              ElevatedButton(
                                onPressed: () =>
                                    _updateStatus(index, 'Rejected'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red),
                                child: Text('Reject'),
                              ),
                              TextButton(
                                onPressed: () => _viewDetails(index),
                                child: Text('Details',
                                    style: TextStyle(color: Colors.blueGrey)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
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
