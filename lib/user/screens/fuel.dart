import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';

class FuelStationList extends StatefulWidget {
  @override
  _FuelStationListState createState() => _FuelStationListState();
}

class _FuelStationListState extends State<FuelStationList> {
  List<Map<String, dynamic>> fuelStations = [];
  String enteredLocation = '';
  String? selectedFuel;
  double quantity = 0.0;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    fetchFuelStations();
  }

  // Fetch fuel stations from Firestore
  Future<void> fetchFuelStations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('fuel').get();

      setState(() {
        fuelStations = querySnapshot.docs.map((doc) {
          return {
            'name': doc['companyName'] ?? 'Unknown Station',
            'location': doc['companyName'] ?? '',
            'address': doc['email'] ?? '',
            'contactNumber': doc['phoneNo'] ?? '',
            'fuels': Map.fromIterable(
              doc['fuels'] ?? [],
              key: (fuel) => fuel['type'],
              value: (fuel) => fuel['price'],
            ),
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching fuel stations: $e');
    }
  }

  List<Map<String, dynamic>> getFilteredStations() {
    if (enteredLocation.isEmpty) {
      return fuelStations;
    }
    return fuelStations
        .where((station) => station['location']!
            .toLowerCase()
            .contains(enteredLocation.toLowerCase()))
        .toList();
  }

  void calculatePrice(String fuel, double pricePerLiter, double qty) {
    setState(() {
      selectedFuel = fuel;
      quantity = qty;
      totalPrice = pricePerLiter * qty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredStations = getFilteredStations();

    return Scaffold(
      appBar: AppBar(
        title: Text('Fuel Stations',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 206, 137, 59),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  enteredLocation = text;
                });
              },
              decoration: InputDecoration(
                labelText: 'Enter Location',
                prefixIcon: Icon(Icons.location_on, color: Colors.blueAccent),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
              ),
            ),
          ),
          if (filteredStations.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'No fuel stations found for the entered location.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredStations.length,
              itemBuilder: (context, index) {
                final station = filteredStations[index];
                return Card(
                  margin: EdgeInsets.all(12),
                  elevation: 8,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(station['name'],
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text('Address: ${station['address']}'),
                        Text('Contact: ${station['contactNumber']}'),
                        SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children:
                              station['fuels'].keys.map<Widget>((fuelType) {
                            final price = station['fuels'][fuelType];
                            return GestureDetector(
                              onTap: () {
                                _showQuantityDialog(
                                    fuelType, price); // Handle tap
                              },
                              child: Chip(
                                label: Text(
                                    '$fuelType ₹${price.toStringAsFixed(2)}'),
                                backgroundColor: Colors.blueAccent,
                                labelStyle: TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showQuantityDialog(String fuelType, double price) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Quantity'),
          content: TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter Quantity in Liters'),
            onChanged: (value) {
              final qty = double.tryParse(value);
              if (qty != null && qty > 0) {
                calculatePrice(fuelType, price, qty);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showConfirmationDialog();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmation'),
        content: Text(
            'You ordered $quantity liters of $selectedFuel for ₹${totalPrice.toStringAsFixed(2)}.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('Close')),
        ],
      ),
    );
  }
}
