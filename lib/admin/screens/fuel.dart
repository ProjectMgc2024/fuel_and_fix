import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageFuelStation extends StatefulWidget {
  @override
  _ManageFuelStationsPageState createState() => _ManageFuelStationsPageState();
}

class _ManageFuelStationsPageState extends State<ManageFuelStation> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String searchQuery = '';
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
      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'companyName': data['companyName'] ?? 'Unknown',
          'companyLicense': data['companyLicense'] ?? 'N/A',
          'companyLogo': data['companyLogo'] ?? '',
          'email': data['email'] ?? 'N/A',
          'phoneNo': data['phoneNo'] ?? 'N/A',
          'ownerName': data['ownerName'] ?? 'Unknown',
          'employees': List<Map<String, dynamic>>.from(data['employees'] ?? []),
          'fuels': List<Map<String, dynamic>>.from(data['fuels'] ?? []),
        };
      }).toList();
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
        backgroundColor: const Color.fromARGB(255, 101, 186, 139),
        elevation: 6,
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
                _buildSearchBar(),
                SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    itemCount: filteredStations.length,
                    itemBuilder: (context, index) {
                      return _fuelStationCard(
                        context,
                        filteredStations[index],
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

  // Search bar widget
  Widget _buildSearchBar() {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchQuery = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Search by company name or owner',
        prefixIcon: Icon(Icons.search, color: Colors.teal),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.teal),
        ),
      ),
    );
  }

  // Filter fuel stations based on search query
  List<Map<String, dynamic>> _getFilteredStations(
      List<Map<String, dynamic>> stations) {
    return stations.where((station) {
      return station['companyName']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          station['ownerName']!
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Fuel station card widget
  Widget _fuelStationCard(BuildContext context, Map<String, dynamic> station) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ExpansionTile(
        leading: station['companyLogo'] != ''
            ? Image.network(
                station['companyLogo'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
            : Icon(Icons.local_gas_station, color: Colors.teal),
        title: Text(
          station['companyName'],
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
        ),
        subtitle: Text(
          'Owner: ${station['ownerName']}',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employees:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                SizedBox(height: 8),
                ...station['employees'].map<Widget>((employee) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(employee['employeeName'] ?? 'Unknown'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: ${employee['employeeEmail'] ?? 'N/A'}'),
                          Text(
                              'Phone: ${employee['employeePhoneNo'] ?? 'N/A'}'),
                          Text('Role: ${employee['employeeRole'] ?? 'N/A'}'),
                        ],
                      ),
                      leading: Icon(Icons.person, color: Colors.teal),
                    ),
                  );
                }).toList(),
                SizedBox(height: 20),
                Text(
                  'Fuels Available:',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                SizedBox(height: 8),
                ...station['fuels'].map<Widget>((fuel) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(fuel['type'] ?? 'Unknown'),
                      subtitle: Text('Price: ${fuel['price']}'),
                      leading:
                          Icon(Icons.local_gas_station, color: Colors.green),
                    ),
                  );
                }).toList(),
              ],
            ),
          )
        ],
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'Delete') {
              _confirmDeleteFuelStation(context, station['id']);
            }
          },
          itemBuilder: (BuildContext context) {
            return [
              PopupMenuItem(value: 'Delete', child: Text('Delete')),
            ];
          },
        ),
      ),
    );
  }

  // Confirmation dialog for fuel station deletion
  void _confirmDeleteFuelStation(BuildContext context, String stationId) {
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
