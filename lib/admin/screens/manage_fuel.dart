import 'package:flutter/material.dart';

class ManageFuelStation extends StatefulWidget {
  @override
  _ManageFuelStationsPageState createState() => _ManageFuelStationsPageState();
}

class _ManageFuelStationsPageState extends State<ManageFuelStation> {
  // List of fuel stations (mock data for now)
  List<Map<String, String>> fuelStations = [
    {'name': 'Station 1', 'location': 'KANNUR', 'status': 'Active'},
    {'name': 'Station 2', 'location': 'THALASSERY', 'status': 'Inactive'},
    {'name': 'Station 3', 'location': 'KUTHUPARAMBA', 'status': 'Active'},
    {'name': 'Station 4', 'location': 'MATTANUR', 'status': 'Inactive'},
    {'name': 'Station 5', 'location': 'IRITTY', 'status': 'Active'},
  ];

  String searchQuery = '';
  String filterStatus = 'All';
  int currentPage = 0;
  final int itemsPerPage = 3; // Items per page for pagination

  @override
  Widget build(BuildContext context) {
    List<Map<String, String>> filteredStations = _getFilteredStations();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Fuel Stations'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchAndFilter(),
            SizedBox(height: 20),
            // Enhanced Add Fuel Station Button
            ElevatedButton.icon(
              onPressed: () {
                _showAddFuelStationDialog(context);
              },
              icon: Icon(Icons.add,
                  color: const Color.fromARGB(255, 231, 19, 7),
                  size: 24), // Plus icon
              label: Text(
                'Add Fuel Station',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: const Color.fromARGB(255, 228, 42, 42),
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                    vertical: 18, horizontal: 30), // Larger padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30), // Rounded corners
                ),
                elevation: 8, // Shadow for the button to make it pop
                shadowColor: Colors.black.withOpacity(0.5), // Shadow color
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStations.length,
                itemBuilder: (context, index) {
                  return _fuelStationCard(
                    context,
                    filteredStations[index]['name']!,
                    filteredStations[index]['location']!,
                    filteredStations[index]['status']!,
                    index,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Search and Filter Section
  Widget _buildSearchAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Search Bar
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search by name or location',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 10),
        // Filter Dropdown
        DropdownButton<String>(
          value: filterStatus,
          onChanged: (newStatus) {
            setState(() {
              filterStatus = newStatus!;
            });
          },
          items: ['All', 'Active', 'Inactive']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Get filtered stations based on search query and status filter
  List<Map<String, String>> _getFilteredStations() {
    return fuelStations.where((station) {
      // Check if search query matches the name or location
      return station['name']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          station['location']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).where((station) {
      // Filter based on status
      return filterStatus == 'All' || station['status'] == filterStatus;
    }).toList();
  }

  // Fuel Station Card Widget
  Widget _fuelStationCard(BuildContext context, String name, String location,
      String status, int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.local_gas_station, color: Colors.blueGrey),
        title: Text(
          name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '$location - $status',
          style: TextStyle(color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Toggle status with a Switch
            Switch(
              value: status == 'Active', // if status is "Active", switch is on
              onChanged: (bool value) {
                setState(() {
                  fuelStations[index]['status'] = value ? 'Active' : 'Inactive';
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  _showEditFuelStationDialog(
                      context, name, location, status, index);
                } else if (value == 'Delete') {
                  _confirmDeleteFuelStation(context, name, index);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(value: 'Edit', child: Text('Edit')),
                  PopupMenuItem(value: 'Delete', child: Text('Delete')),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  // Add Fuel Station Dialog
  void _showAddFuelStationDialog(BuildContext context) {
    final _nameController = TextEditingController();
    final _locationController = TextEditingController();
    String _status = 'Active';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Fuel Station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Station Name'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              DropdownButton<String>(
                value: _status,
                onChanged: (newStatus) {
                  setState(() {
                    _status = newStatus!;
                  });
                },
                items: ['Active', 'Inactive']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  fuelStations.add({
                    'name': _nameController.text,
                    'location': _locationController.text,
                    'status': _status,
                  });
                });
                Navigator.pop(context);
              },
              child: Text('Add Station'),
            ),
          ],
        );
      },
    );
  }

  // Edit Fuel Station Dialog
  void _showEditFuelStationDialog(BuildContext context, String name,
      String location, String status, int index) {
    final _nameController = TextEditingController(text: name);
    final _locationController = TextEditingController(text: location);
    String _status = status;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Fuel Station'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Station Name'),
              ),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              // Dropdown to choose the station's status
              DropdownButton<String>(
                value:
                    _status, // The current status will be selected by default
                onChanged: (newStatus) {
                  setState(() {
                    _status = newStatus!;
                  });
                },
                items: ['Active', 'Inactive']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  fuelStations[index] = {
                    'name': _nameController.text,
                    'location': _locationController.text,
                    'status': _status,
                  };
                });
                Navigator.pop(context);
              },
              child: Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  // Confirm Delete Fuel Station
  void _confirmDeleteFuelStation(BuildContext context, String name, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Fuel Station'),
          content: Text('Are you sure you want to delete $name?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  fuelStations.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
