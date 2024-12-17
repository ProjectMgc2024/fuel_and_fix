import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleRepairApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VehicleRepairCategories(),
    );
  }
}

class VehicleRepairCategories extends StatefulWidget {
  @override
  _VehicleRepairCategoriesState createState() =>
      _VehicleRepairCategoriesState();
}

class _VehicleRepairCategoriesState extends State<VehicleRepairCategories> {
  String _enteredLocation = ''; // Variable to store user entered location

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Repair Services'),
        centerTitle: true,
        elevation: 10,
        backgroundColor: const Color.fromARGB(255, 232, 145, 47),
        actions: [
          TextButton.icon(
            icon: Icon(Icons.expand_more, color: Colors.white),
            label: Text('Show All', style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ShowAllWorkshopsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (text) {
                setState(() {
                  _enteredLocation = text;
                });
              },
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                labelText: 'Enter Location (e.g. Location A)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_enteredLocation.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please enter a valid location.')),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => WorkshopListScreen(
                          location: _enteredLocation.toLowerCase(),
                        ),
                      ),
                    );
                  }
                },
                icon: Icon(Icons.search, size: 20),
                label: Text('Show Workshops'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkshopListScreen extends StatelessWidget {
  final String location;

  WorkshopListScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workshops in $location'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 232, 145, 47),
      ),
      body: StreamBuilder(
        // Fetch workshops filtered by location
        stream: FirebaseFirestore.instance
            .collection('repair')
            .where('location', isEqualTo: location)
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final workshops = snapshot.data?.docs ?? [];

          if (workshops.isEmpty) {
            return Center(child: Text('No workshops found for this location.'));
          }

          return ListView.builder(
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];

              return Card(
                margin: EdgeInsets.all(12),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop['companyName'] ?? 'No Name',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Owner: ${workshop['ownerName'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text('Contact: ${workshop['phoneNo'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text(
                        'Vehicle Types: ${workshop['vehicleTypes']?.join(', ') ?? 'N/A'}',
                      ),
                      SizedBox(height: 8),
                      Text('Location: ${workshop['location'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ShowAllWorkshopsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Workshops'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 232, 145, 47),
      ),
      body: StreamBuilder(
        // Fetch all workshops
        stream: FirebaseFirestore.instance.collection('repair').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final workshops = snapshot.data?.docs ?? [];

          return ListView.builder(
            itemCount: workshops.length,
            itemBuilder: (context, index) {
              final workshop = workshops[index];

              return Card(
                margin: EdgeInsets.all(12),
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        workshop['companyName'] ?? 'No Name',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text('Owner: ${workshop['ownerName'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text('Contact: ${workshop['phoneNo'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text(
                          'Vehicle Types: ${workshop['vehicleTypes'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                      Text('Location: ${workshop['location'] ?? 'N/A'}'),
                      SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
