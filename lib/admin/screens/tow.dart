import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageTowStation extends StatefulWidget {
  @override
  _ManageTowStationsPageState createState() => _ManageTowStationsPageState();
}

class _ManageTowStationsPageState extends State<ManageTowStation> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> towStations = [];
  String searchQuery = '';
  String filterStatus = 'All';

  @override
  void initState() {
    super.initState();
    _fetchTowStations();
  }

  // Fetch Tow Stations from Firestore
  Future<void> _fetchTowStations() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('tow').get();
      List<Map<String, dynamic>> stations = snapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'],
                'phoneNo': doc['phoneNo'],
                'status': doc['status'],
                'towId': doc['towId'],
                'workers': List<String>.from(doc['workers']),
              })
          .toList();
      setState(() {
        towStations = stations;
      });
    } catch (e) {
      print('Error fetching tow stations: $e');
    }
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
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
        DropdownButton<String>(
          value: filterStatus,
          onChanged: (newStatus) {
            setState(() {
              filterStatus = newStatus!;
            });
          },
          items: ['All', 'Available', 'Unavailable']
              .map((value) => DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  ))
              .toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredStations() {
    return towStations.where((station) {
      final matchesSearchQuery = station['name']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          station['towId']
              .toLowerCase()
              .contains(searchQuery.toLowerCase()); // Search by name or towId
      final matchesStatus =
          filterStatus == 'All' || station['status'] == filterStatus;
      return matchesSearchQuery && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredStations = _getFilteredStations();

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Tow Stations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSearchAndFilter(),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filteredStations.length,
                itemBuilder: (context, index) {
                  final station = filteredStations[index];
                  return _towStationCard(context, station, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _towStationCard(
      BuildContext context, Map<String, dynamic> station, int index) {
    return Card(
      child: ListTile(
        title: Text(station['name']),
        subtitle: Text(
            '${station['towId']} - ${station['status']} - Phone: ${station['phoneNo']}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _confirmDeleteTowStation(context, station),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTowStation(
      BuildContext context, Map<String, dynamic> station) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Delete Tow Station'),
          content: Text('Are you sure you want to delete this tow station?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                _firestore.collection('tow').doc(station['id']).delete();
                setState(() {
                  towStations.removeWhere((s) => s['id'] == station['id']);
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
