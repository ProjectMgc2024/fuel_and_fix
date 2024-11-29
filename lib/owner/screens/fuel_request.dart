import 'package:flutter/material.dart';

class FuelFillingRequest extends StatefulWidget {
  @override
  _FuelFillingRequestState createState() => _FuelFillingRequestState();
}

class _FuelFillingRequestState extends State<FuelFillingRequest> {
  // Fuel requests with realistic details (without the date field)
  List<Map<String, String>> fuelRequests = [
    {
      'vehicle': 'Car - KL58AJ9842',
      'status': 'Pending',
      'priority': 'High',
      'fuelAmount': '40',
      'cost': '80 Rs',
      'contact': '123-456-7890',
      'location': '123 Main St, City Center',
      'notes': 'Urgent request, needs immediate fuel delivery.',
    },
    {
      'vehicle': 'Truck - KL58V9841',
      'status': 'Approved',
      'priority': 'Medium',
      'fuelAmount': '150',
      'cost': '300 Rs',
      'contact': '098-765-4321',
      'location': '456 Industrial Ave, Factory Zone',
      'notes': 'Scheduled delivery for tomorrow.',
    },
    {
      'vehicle': 'Bike - KL17J7711',
      'status': 'Completed',
      'priority': 'Low',
      'fuelAmount': '10',
      'cost': '20 Rs',
      'contact': '555-333-1111',
      'location': '789 Elm St, Downtown',
      'notes': 'Request completed without issues.',
    },
  ];

  // Filters to show requests based on status
  String selectedStatus = 'All';

  TextEditingController searchController = TextEditingController();

  // Calculate cost dynamically based on fuel amount and cost per liter
  String calculateCost(String fuelAmount) {
    double amount = double.tryParse(fuelAmount) ?? 0.0;
    double costPerLiter = 2.0; // Assuming a cost per liter value
    double totalCost = amount * costPerLiter;
    return '\$${totalCost.toStringAsFixed(2)}';
  }

  List<Map<String, String>> getFilteredRequests() {
    // Filter requests based on status and search query
    String query = searchController.text.toLowerCase();
    return fuelRequests.where((request) {
      bool matchesStatus =
          selectedStatus == 'All' || request['status'] == selectedStatus;
      bool matchesQuery = request['vehicle']!.toLowerCase().contains(query);
      return matchesStatus && matchesQuery;
    }).toList();
  }

  // Update request status and show a notification
  void updateStatus(int index, String newStatus) {
    setState(() {
      fuelRequests[index]['status'] = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Status updated to $newStatus')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Requests'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () async {
              // Show status filter options
              String? selected = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text('Filter by Status'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RadioListTile<String>(
                          title: Text('All'),
                          value: 'All',
                          groupValue: selectedStatus,
                          onChanged: (value) {
                            Navigator.pop(context, value);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Pending'),
                          value: 'Pending',
                          groupValue: selectedStatus,
                          onChanged: (value) {
                            Navigator.pop(context, value);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Approved'),
                          value: 'Approved',
                          groupValue: selectedStatus,
                          onChanged: (value) {
                            Navigator.pop(context, value);
                          },
                        ),
                        RadioListTile<String>(
                          title: Text('Completed'),
                          value: 'Completed',
                          groupValue: selectedStatus,
                          onChanged: (value) {
                            Navigator.pop(context, value);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
              if (selected != null) {
                setState(() {
                  selectedStatus = selected;
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar to filter requests
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by vehicle',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),
            SizedBox(height: 16),
            // List of fuel requests with dynamic filtering
            Expanded(
              child: ListView.builder(
                itemCount: getFilteredRequests().length,
                itemBuilder: (context, index) {
                  var request = getFilteredRequests()[index];
                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vehicle Info
                          Text(
                            request['vehicle']!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          SizedBox(height: 8),
                          // Priority Badge
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: request['priority'] == 'High'
                                  ? Colors.red
                                  : request['priority'] == 'Medium'
                                      ? Colors.orange
                                      : Colors.green,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'Priority: ${request['priority']}',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Fuel amount and cost
                          Text(
                            'Fuel Requested: ${request['fuelAmount']} liters',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black45),
                          ),
                          Text(
                            'Total Cost: ${calculateCost(request['fuelAmount']!)}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black45),
                          ),
                          SizedBox(height: 8),
                          // Status Section with Progress Bar
                          LinearProgressIndicator(
                            value: request['status'] == 'Pending'
                                ? 0.2
                                : request['status'] == 'Approved'
                                    ? 0.5
                                    : request['status'] == 'In Progress'
                                        ? 0.8
                                        : 1.0,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              request['status'] == 'Pending'
                                  ? Colors.orange
                                  : request['status'] == 'Approved'
                                      ? Colors.green
                                      : request['status'] == 'In Progress'
                                          ? Colors.blue
                                          : Colors.grey,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Action buttons for Pending, Approved, In Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (request['status'] == 'Pending') ...[
                                ElevatedButton(
                                  onPressed: () {
                                    updateStatus(index, 'Approved');
                                  },
                                  child: Text('Approve'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    updateStatus(index, 'Rejected');
                                  },
                                  child: Text('Reject'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red),
                                ),
                              ],
                              if (request['status'] == 'Approved') ...[
                                ElevatedButton(
                                  onPressed: () {
                                    updateStatus(index, 'In Progress');
                                  },
                                  child: Text('Start'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue),
                                ),
                              ],
                              if (request['status'] == 'In Progress') ...[
                                ElevatedButton(
                                  onPressed: () {
                                    updateStatus(index, 'Completed');
                                  },
                                  child: Text('Complete'),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.purple),
                                ),
                              ],
                            ],
                          ),
                          SizedBox(height: 8),
                          // Customer's contact info
                          Text(
                            'Contact: ${request['contact']}',
                            style:
                                TextStyle(fontSize: 14, color: Colors.black54),
                          ),
                          SizedBox(height: 8),
                          // Customer's location with a link to maps
                          TextButton(
                            onPressed: () {
                              // Open in Google Maps or other map application
                            },
                            child: Text(
                              'Location: ${request['location']}',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.blueAccent),
                            ),
                          ),
                          SizedBox(height: 8),
                          // Notes section
                          if (request['notes'] != '') ...[
                            Text(
                              'Notes: ${request['notes']}',
                              style: TextStyle(
                                  fontSize: 14, fontStyle: FontStyle.italic),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
