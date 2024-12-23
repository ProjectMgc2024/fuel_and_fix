import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:fuel_and_fix/user/screens/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';

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
  String? currentUserId;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    fetchCurrentUserId();
    fetchFuelStations();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> fetchCurrentUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        currentUserId = user?.uid;
      });
    } catch (e) {
      print('Error fetching current user ID: $e');
    }
  }

  Future<void> fetchFuelStations() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('fuel').get();

      setState(() {
        fuelStations = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'name': doc['companyName'] ?? 'Unknown Station',
            'location': doc['additionalData']['location_name'] ?? '',
            'latitude': doc['additionalData']['latitude'] ?? '',
            'longitude': doc['additionalData']['longitude'] ?? '',
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

  Future<void> initiatePayment(String ownerId) async {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': (totalPrice * 100).toInt(), // Amount in paisa
      'name': 'Fuel & Fix',
      'description': 'Fuel purchase',
      'prefill': {
        'contact': '1234567890',
        'email': 'test@example.com',
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error initiating payment: $e');
    }
  }

  String? oId;

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    print('Payment successful: ${response.paymentId}');
    await createRequest(response.paymentId!, true);
    _showSuccessDialog();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment failed: ${response.code} | ${response.message}');
    _showErrorDialog('Payment failed. Please try again.');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External wallet selected: ${response.walletName}');
  }

  Future<void> createRequest(String paymentId, bool isPayment) async {
    if (currentUserId == null) {
      print('User ID not available');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('fuel')
          .doc(oId)
          .collection('request')
          .add({
        'status': false,
        'timestamp': Timestamp.now(),
        'userId': currentUserId,
        'litres': quantity,
        'fuelType': selectedFuel,
        'paymentId': paymentId,
        'isPayment': isPayment,
      });
    } catch (e) {
      print('Error creating request: $e');
    }
  }

  Future<void> _openGoogleMaps(
      {required double latitude, required double longitude}) async {
    final Uri googleMapsUri = Uri.parse(
        "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude");

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
    } else {
      throw "Could not launch Google Maps";
    }
  }

  void _showQuantityDialog(String fuelType, dynamic price, String ownerId) {
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
              final pre = double.tryParse(price.toString());
              if (qty != null && qty > 0) {
                calculatePrice(fuelType, pre!, qty);
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
                oId = ownerId;
                initiatePayment(ownerId);
              },
              child: Text('Proceed to Pay'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order Confirmation'),
        content: Text(
            'You ordered $quantity liters of $selectedFuel for ₹${totalPrice.toStringAsFixed(2)}. Request has been placed successfully.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text('OK')),
        ],
      ),
    );
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
                        Row(
                          children: [
                            Text(station['location'],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            Spacer(),
                            IconButton(
                                onPressed: () {
                                  _openGoogleMaps(
                                      latitude: station['latitude'],
                                      longitude: station['longitude']);
                                },
                                icon: Icon(Icons.location_on))
                          ],
                        ),
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
                                    fuelType, price, station['id']);
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
}
