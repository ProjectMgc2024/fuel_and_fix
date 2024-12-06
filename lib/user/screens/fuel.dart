import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';

class FuelStationApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FuelStationList(),
    );
  }
}

class FuelStationList extends StatefulWidget {
  @override
  _FuelStationListState createState() => _FuelStationListState();
}

class _FuelStationListState extends State<FuelStationList> {
  final List<Map<String, dynamic>> fuelStations = [
    {
      'name': 'Indian Oil Fuel Station',
      'location': 'Location A',
      'address': '123, ABC Road, Location A',
      'contactNumber': '+91 1234567890',
      'fuels': {
        'Petrol': 103.0, // price per liter
        'Diesel': 93.0,
      }
    },
    {
      'name': 'HP Station',
      'location': 'Location B',
      'address': '456, XYZ Road, Location B',
      'contactNumber': '+91 2345678901',
      'fuels': {
        'Petrol': 101.5,
        'Diesel': 91.5,
        'CNG': 72.0,
      }
    },
    {
      'name': 'Nayara Fuel Station',
      'location': 'Location A',
      'address': '789, PQR Road, Location A',
      'contactNumber': '+91 3456789012',
      'fuels': {
        'Petrol': 104.0,
        'Diesel': 94.0,
        'CNG': 70.5,
      }
    },
    {
      'name': 'Shell Fuel Station',
      'location': 'Location C',
      'address': '321, DEF Road, Location C',
      'contactNumber': '+91 4567890123',
      'fuels': {
        'Petrol': 105.5,
        'Diesel': 95.0,
        'CNG': 71.0,
      }
    },
    {
      'name': 'Essar Fuel Hub',
      'location': 'Location B',
      'address': '654, GHI Road, Location B',
      'contactNumber': '+91 5678901234',
      'fuels': {
        'Petrol': 100.0,
        'Diesel': 90.0,
        'CNG': 68.0,
      }
    },
    {
      'name': 'Reliance Fuel Station',
      'location': 'Location C',
      'address': '987, JKL Road, Location C',
      'contactNumber': '+91 6789012345',
      'fuels': {
        'Petrol': 106.0,
        'Diesel': 96.0,
        'CNG': 73.0,
      }
    },
  ];

  int? selectedStationIndex;
  String? selectedFuel;
  double quantity = 0.0;
  double totalPrice = 0.0;

  String enteredLocation = '';

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

  void showConfirmDialog() {
    if (selectedFuel != null && quantity > 0) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Confirm Your Order",
                style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fuel: $selectedFuel',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Quantity: $quantity liters',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Total Price: ₹${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    selectedFuel = null;
                    quantity = 0.0;
                    totalPrice = 0.0;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order canceled. No payment processed.'),
                      backgroundColor: const Color.fromARGB(255, 219, 40, 27),
                    ),
                  );
                },
                child: Text('Cancel', style: TextStyle(color: Colors.red)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Payment confirmed! ₹${totalPrice.toStringAsFixed(2)} paid successfully.'),
                      backgroundColor: Colors.green,
                    ),
                  );

                  setState(() {
                    selectedFuel = null;
                    quantity = 0.0;
                    totalPrice = 0.0;
                  });

                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Completed!'),
                        content: Text(
                            'Your payment has been successfully processed.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Text('Confirm'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select fuel and quantity first!'),
          backgroundColor: const Color.fromARGB(255, 197, 34, 9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredStations = getFilteredStations();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Fuel Stations',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 206, 137, 59),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to home screen and remove all previous screens from the stack
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      HomeScreen()), // Navigate to the home screen
              (route) =>
                  false, // This ensures that the previous routes are cleared
            );
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (text) {
                      setState(() {
                        enteredLocation = text;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Enter Location (e.g., Location A)',
                      prefixIcon:
                          Icon(Icons.location_on, color: Colors.blueAccent),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide: BorderSide(color: Colors.blueAccent),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        borderSide:
                            BorderSide(color: Colors.blueAccent, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              color: Colors.orange,
                              size: 28,
                            ),
                            Text(
                              station['name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(station['address'],
                            style: TextStyle(fontSize: 14)),
                        Text('Contact: ${station['contactNumber']}',
                            style: TextStyle(fontSize: 14)),
                        SizedBox(height: 15),
                        Wrap(
                          spacing: 15,
                          children:
                              station['fuels'].keys.map<Widget>((fuelType) {
                            final price = station['fuels'][fuelType];
                            Color chipColor;

                            // Assign a color based on the fuel type
                            switch (fuelType) {
                              case 'Petrol':
                                chipColor = const Color.fromARGB(
                                    255, 223, 143, 51); // Green for Petrol
                                break;
                              case 'Diesel':
                                chipColor = const Color.fromARGB(
                                    255, 67, 139, 172); // Blue for Diesel
                                break;
                              case 'CNG':
                                chipColor = Colors.green; // Orange for CNG
                                break;
                              default:
                                chipColor = Colors.grey; // Default color
                            }

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFuel = fuelType;
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Select Quantity'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Fuel: $fuelType'),
                                          Text(
                                              'Price per Liter: ₹${price.toStringAsFixed(2)}'),
                                          TextField(
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                                labelText:
                                                    'Quantity in Liters'),
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                final qty =
                                                    double.tryParse(value);
                                                if (qty != null && qty > 0) {
                                                  setState(() {
                                                    quantity = qty;
                                                    totalPrice = qty * price!;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                          SizedBox(height: 20),
                                          ElevatedButton(
                                            onPressed: () {
                                              calculatePrice(
                                                  fuelType, price, quantity);
                                              Navigator.pop(context);
                                              showConfirmDialog();
                                            },
                                            child: Text('Confirm Quantity'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Chip(
                                label: Text(
                                  '$fuelType ₹${price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.white),
                                ),
                                backgroundColor:
                                    chipColor, // Set the dynamic background color
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
}
