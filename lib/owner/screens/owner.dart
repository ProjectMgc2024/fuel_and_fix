import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/fuel/login.dart';
import 'package:fuel_and_fix/owner/screens/repair/login.dart';
import 'package:fuel_and_fix/owner/screens/tow/login.dart';

class OwnerIntro extends StatefulWidget {
  @override
  _OwnerIntroState createState() => _OwnerIntroState();
}

class _OwnerIntroState extends State<OwnerIntro> {
  // New variable to store the selected service
  String? _selectedService;

  void _nextStep() {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a service")),
      );
      return;
    }

    // Navigate based on the selected service
    if (_selectedService == 'Fuel') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => FuelLoginScreen()),
        (Route<dynamic> route) => false, // Removes all the previous routes
      );
    } else if (_selectedService == 'Repair') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => RepairLoginScreen()),
        (Route<dynamic> route) => false,
      );
    } else if (_selectedService == 'Tow') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => TowLoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('asset/pic4.jpg'),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Choose Your Service',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 60),

              // Container for radio button options
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedService = 'Fuel';
                      });
                    },
                    child: Card(
                      elevation: 5,
                      color: _selectedService == 'Fuel'
                          ? Colors.green[200]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_gas_station,
                              color: _selectedService == 'Fuel'
                                  ? Colors.white
                                  : Colors.black,
                              size: 40,
                            ),
                            Text(
                              'Fuel',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedService == 'Fuel'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedService = 'Repair';
                      });
                    },
                    child: Card(
                      elevation: 5,
                      color: _selectedService == 'Repair'
                          ? Colors.red[200]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.build,
                              color: _selectedService == 'Repair'
                                  ? Colors.white
                                  : Colors.black,
                              size: 40,
                            ),
                            Text(
                              'Repair',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedService == 'Repair'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedService = 'Tow';
                      });
                    },
                    child: Card(
                      elevation: 5,
                      color: _selectedService == 'Tow'
                          ? Colors.blue[200]
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.directions_car,
                              color: _selectedService == 'Tow'
                                  ? Colors.white
                                  : Colors.black,
                              size: 40,
                            ),
                            Text(
                              'Tow',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _selectedService == 'Tow'
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),

              // Next Button
              ElevatedButton(
                onPressed: _nextStep,
                child: Text(
                  'Next',
                  style: TextStyle(
                      color: const Color.fromARGB(255, 201, 202, 201)),
                ),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size(100, 50),
                    backgroundColor: const Color.fromARGB(255, 59, 126, 133)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
