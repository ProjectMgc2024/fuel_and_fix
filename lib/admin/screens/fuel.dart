import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageFuelStation extends StatefulWidget {
  @override
  _ManageFuelStationsPageState createState() => _ManageFuelStationsPageState();
}

class _ManageFuelStationsPageState extends State<ManageFuelStation> {
  // Firestore instance
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String searchQuery = '';
  String filterStatus = 'All';
  int currentPage = 0;
  final int itemsPerPage = 3;

  // Fuel Station data from Firestore
  late Future<List<Map<String, dynamic>>> fuelStations;

  @override
  void initState() {
    super.initState();
    fuelStations = fetchFuelStations();
  }

  // Fetch fuel stations from Firestore
  Future<List<Map<String, dynamic>>> fetchFuelStations() async {
    try {
      QuerySnapshot querySnapshot =
          await _firebaseFirestore.collection('fuel').get();
      List<Map<String, dynamic>> stations = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          'companyId': doc['companyId'],
          'companyName': doc['companyName'],
          'employees': List<String>.from(doc['employees']),
          'fuels': List<Map<String, dynamic>>.from(doc['fuels']),
          'owner': doc['owner'],
        };
      }).toList();
      return stations;
    } catch (e) {
      print('Error fetching fuel stations: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Fuel Stations'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fuelStations,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading data'));
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No fuel stations available'));
            }

            List<Map<String, dynamic>> filteredStations =
                _getFilteredStations(snapshot.data!);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchAndFilter(),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStations.length,
                    itemBuilder: (context, index) {
                      return _fuelStationCard(
                        context,
                        filteredStations[index],
                        index,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              labelText: 'Search by company name or location',
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
          items: ['All', 'Active', 'Inactive']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> _getFilteredStations(
      List<Map<String, dynamic>> stations) {
    return stations.where((station) {
      return station['companyName']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          station['owner']!.toLowerCase().contains(searchQuery.toLowerCase());
    }).where((station) {
      return filterStatus == 'All' || station['status'] == filterStatus;
    }).toList();
  }

  Widget _fuelStationCard(
      BuildContext context, Map<String, dynamic> station, int index) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        leading: Icon(Icons.local_gas_station, color: Colors.blueGrey),
        title: Text(
          station['companyName'],
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          '${station['owner']} - ${station['companyId']}',
          style: TextStyle(color: Colors.black54),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: station['status'] == 'Active',
              onChanged: (bool value) {
                setState(() {
                  station['status'] = value ? 'Active' : 'Inactive';
                  _firebaseFirestore
                      .collection('fuel')
                      .doc(station['id'])
                      .update({'status': station['status']});
                });
              },
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  _showEditFuelStationDialog(context, station, index);
                } else if (value == 'Delete') {
                  _confirmDeleteFuelStation(context, station['id'], index);
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

  void _showEditFuelStationDialog(
      BuildContext context, Map<String, dynamic> station, int index) {
    final _nameController = TextEditingController(text: station['companyName']);
    final _locationController =
        TextEditingController(text: station['location']);
    String _status = station['status'];

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
                      value: value, child: Text(value));
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _firebaseFirestore
                      .collection('fuel')
                      .doc(station['id'])
                      .update({
                    'companyName': _nameController.text,
                    'location': _locationController.text,
                    'status': _status,
                  });
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

  void _confirmDeleteFuelStation(
      BuildContext context, String stationId, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Fuel Station'),
          content: Text('Are you sure you want to delete this fuel station?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _firebaseFirestore.collection('fuel').doc(stationId).delete();
                  fuelStations = fetchFuelStations();
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
