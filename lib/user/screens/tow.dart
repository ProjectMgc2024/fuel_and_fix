import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';

class TowingServiceApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TowingServiceCategories(),
    );
  }
}

class TowingServiceCategories extends StatefulWidget {
  @override
  _TowingServiceCategoriesState createState() =>
      _TowingServiceCategoriesState();
}

class _TowingServiceCategoriesState extends State<TowingServiceCategories> {
  final List<String> categories = [
    'Emergency Tow',
    'Accident Tow',
    'Motorcycle Tow',
    'Long-Distance Tow',
  ];

  // Track selected service provider for each category
  String? selectedCategory;
  String? selectedServiceProvider;
  bool isBookingConfirmed = false;
  double totalPrice = 0.0;
  double selectedDistance = 0.0;

  // Track the service providers for each category
  Map<String, List<Map<String, dynamic>>> serviceStations = {
    'Emergency Tow': [
      {
        'name': 'Quick Tow Services',
        'price': 1000.0,
        'details': 'Includes emergency towing for the first 20 km.',
        'baseDistance': 20.0, // Base distance
      },
      {
        'name': 'Emergency Response Tow',
        'price': 1200.0,
        'details': 'Includes emergency towing for the first 30 km.',
        'baseDistance': 30.0,
      },
    ],
    'Accident Tow': [
      {
        'name': 'Rapid Tow Services',
        'price': 2000.0,
        'details': 'Includes towing for the first 50 km.',
        'baseDistance': 50.0,
      },
      {
        'name': 'TowFast Company',
        'price': 2200.0,
        'details': 'Includes towing for the first 50 km.',
        'baseDistance': 50.0,
      },
    ],
    'Motorcycle Tow': [
      {
        'name': 'Bike Tow Experts',
        'price': 800.0,
        'details': 'Includes towing for the first 30 km.',
        'baseDistance': 30.0,
      },
      {
        'name': 'Motorcycle Rescue',
        'price': 850.0,
        'details': 'Includes towing for the first 30 km.',
        'baseDistance': 30.0,
      },
    ],
    'Long-Distance Tow': [
      {
        'name': 'LongHaul Tow Experts',
        'price': 5000.0,
        'details': 'Includes towing for the first 500 km.',
        'baseDistance': 500.0,
      },
      {
        'name': 'CrossCountry Tow',
        'price': 5200.0,
        'details': 'Includes towing for the first 500 km.',
        'baseDistance': 500.0,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_taxi, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Towing Services',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: InkWell(
                      onTap: isBookingConfirmed
                          ? null // Disable category selection after booking
                          : () {
                              setState(() {
                                selectedCategory = category;
                                selectedServiceProvider =
                                    null; // Reset selected provider
                              });
                            },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _getCategoryIcon(category),
                          SizedBox(height: 10),
                          Text(
                            category,
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (selectedCategory != null && !isBookingConfirmed)
              Column(
                children: [
                  for (var station in serviceStations[selectedCategory!]!)
                    Card(
                      margin: EdgeInsets.all(8),
                      elevation: 5,
                      child: ListTile(
                        title: Text(station['name']),
                        subtitle: Text(station['details']),
                        trailing: Text('\$${station['price']}'),
                        tileColor: selectedServiceProvider == station['name']
                            ? Colors.orangeAccent
                            : Colors.white,
                        onTap: () {
                          setState(() {
                            selectedServiceProvider =
                                station['name']; // Select only one provider
                            // Set initial distance and calculate the price
                            selectedDistance = station['baseDistance'];
                            totalPrice = station['price'];
                          });
                        },
                      ),
                    ),
                  if (selectedServiceProvider != null)
                    Column(
                      children: [
                        // Slider for selecting distance
                        Slider(
                          value: selectedDistance,
                          min: 0,
                          max: 1000,
                          divisions: 100,
                          label: '${selectedDistance.toStringAsFixed(0)} km',
                          onChanged: (double value) {
                            setState(() {
                              selectedDistance = value;
                              // Update price based on the selected distance
                              double extraDistance = selectedDistance -
                                  serviceStations[selectedCategory!]!
                                          .firstWhere((s) =>
                                              s['name'] ==
                                              selectedServiceProvider)[
                                      'baseDistance'];
                              totalPrice = serviceStations[selectedCategory!]!
                                      .firstWhere((s) =>
                                          s['name'] ==
                                          selectedServiceProvider)['price'] +
                                  extraDistance * 5; // $5 per additional km
                            });
                          },
                        ),
                        Text(
                            'Selected Distance: ${selectedDistance.toStringAsFixed(0)} km'),
                        Text('Total Price: \$${totalPrice.toStringAsFixed(2)}'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ServiceDetailsScreen(
                                  category: selectedCategory!,
                                  serviceProvider: selectedServiceProvider!,
                                  price: totalPrice,
                                  distance: selectedDistance,
                                  onCancelBooking: _cancelBooking,
                                ),
                              ),
                            );
                            setState(() {
                              isBookingConfirmed =
                                  true; // Lock further selection
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 30),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          child: Text('Proceed to Confirm'),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _cancelBooking() {
    setState(() {
      isBookingConfirmed = false;
      selectedCategory = null;
      selectedServiceProvider = null;
      selectedDistance = 0.0;
      totalPrice = 0.0;
    });
  }

  Icon _getCategoryIcon(String category) {
    switch (category) {
      case 'Emergency Tow':
        return Icon(Icons.local_taxi, color: Colors.red, size: 50);
      case 'Accident Tow':
        return Icon(Icons.car_repair, color: Colors.green, size: 50);
      case 'Motorcycle Tow':
        return Icon(Icons.motorcycle, color: Colors.orange, size: 50);
      case 'Long-Distance Tow':
        return Icon(Icons.travel_explore, color: Colors.purple, size: 50);
      default:
        return Icon(Icons.local_taxi, color: Colors.grey, size: 50);
    }
  }
}

class ServiceDetailsScreen extends StatelessWidget {
  final String category;
  final String serviceProvider;
  final double price;
  final double distance;
  final VoidCallback onCancelBooking;

  ServiceDetailsScreen({
    required this.category,
    required this.serviceProvider,
    required this.price,
    required this.distance,
    required this.onCancelBooking,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$category - $serviceProvider Details'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: $serviceProvider', style: TextStyle(fontSize: 20)),
            SizedBox(height: 10),
            Text('Price: \$${price.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Distance: ${distance.toStringAsFixed(0)} km',
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Booking Confirmed'),
                      content: Text('Your booking has been confirmed.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            onCancelBooking();
                            Navigator.pop(context);
                          },
                          child: Text('OK'),
                        ),
                      ],
                    );
                  },
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text('Confirm Booking'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                onCancelBooking(); // Cancel booking
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text('Cancel Booking'),
            ),
          ],
        ),
      ),
    );
  }
}
