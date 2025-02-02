import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/feedback.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class WorkshopScreen extends StatefulWidget {
  @override
  _WorkshopScreenState createState() => _WorkshopScreenState();
}

class _WorkshopScreenState extends State<WorkshopScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Razorpay _razorpay;
  Map<String, dynamic>? _currentWorkshop;
  String? _currentLocationName;
  bool _isUpdatingLocation = false; // To show loading indicator
  String enteredLocation = ''; // Variable to store search text

  // Define a map to hold common vehicle problems and their checkbox state.
  Map<String, bool> vehicleProblems = {
    'Engine Trouble': false,
    'Brake Issues': false,
    'Overheating': false,
    'Flat Tire': false,
    'Light Issue': false
  };

  // TextEditingController for the vehicle situation input.
  TextEditingController _vehicleSituationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _vehicleSituationController.dispose();
    _razorpay.clear();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _getWorkshops() async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('repair')
        .where('status', isEqualTo: true) // Ensure status is true
        .where('isApproved', isEqualTo: true) // Filter for approved companies
        .get();

    List<Map<String, dynamic>> workshops = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      workshops.add({
        'id': doc.id,
        ...data,
      });
    }
    return workshops;
  }

  // Function to launch the phone dialer.
  _launchPhone(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunch(phoneUri.toString())) {
      await launch(phoneUri.toString());
    } else {
      throw 'Could not launch phone number';
    }
  }

  // Filter workshops based on the entered location.
  List<Map<String, dynamic>> getFilteredWorkshops(
      List<Map<String, dynamic>> workshops) {
    if (enteredLocation.isEmpty) {
      return workshops;
    }
    return workshops
        .where((workshop) =>
            workshop['additionalData']?['location_name']
                ?.toLowerCase()
                .contains(enteredLocation.toLowerCase()) ??
            false)
        .toList();
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get the current timestamp.
      DateTime timestamp = DateTime.now();

      // Fetch the user's location name from the user collection.
      DocumentSnapshot userDoc =
          await _firestore.collection('user').doc(user.uid).get();
      String userLocation =
          userDoc['additionalData']['location_name'] ?? 'Unknown Location';

      // Collect selected vehicle problems.
      List<String> selectedProblems = vehicleProblems.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      // Prepare the data to be saved in Firestore.
      Map<String, dynamic> requestData = {
        'isPayment': true,
        'paymentId': response.paymentId,
        'status': true,
        'timestamp': timestamp,
        'userId': user.uid,
        'userLocation': userLocation,
        'vehicleSituation': _vehicleSituationController.text,
        'vehicleProblems': selectedProblems,
      };

      // Save the data to the Firestore request subcollection.
      try {
        await _firestore
            .collection('repair')
            .doc(_currentWorkshop!['id'])
            .collection('request')
            .add(requestData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Payment and request submitted successfully!')),
        );
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit request: $error')),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Payment Failed: ${response.message}")),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text("External Wallet Selected: ${response.walletName}")),
    );
  }

  void _payWithRazorpay(Map<String, dynamic> workshop) {
    var options = {
      'key': 'rzp_test_D5Vh3hyi1gRBV0',
      'amount': 50000, // Amount in paise (500.00 INR)
      'name': 'Repair Service',
      'description': 'Repair service payment',
      'prefill': {
        'contact': '1234567890',
        'email': 'user@example.com',
      },
    };

    try {
      _currentWorkshop = workshop;
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // Define a flag to track location fetching status.
  bool _locationFetched = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isUpdatingLocation = true;
    });

    // Get the current position.
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Reverse geocode to get the location name.
    List<Placemark> placemarks = await GeocodingPlatform.instance!
        .placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        _currentLocationName =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";
        _locationFetched = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Current Location: $_currentLocationName')),
      );

      // Update the user collection with the current location.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _firestore.collection('user').doc(user.uid).update({
          'additionalData.latitude': position.latitude,
          'additionalData.longitude': position.longitude,
          'additionalData.location_name': _currentLocationName,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location updated successfully!')),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update location: $error')),
          );
        });
      }
    }

    setState(() {
      _isUpdatingLocation = false;
    });
  }

  // Dialog to input vehicle situation and select vehicle problems.
  void _showLocationAndPaymentDialog(Map<String, dynamic> workshop) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside.
      builder: (BuildContext context) {
        // Use StatefulBuilder for local state management in the dialog.
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Select Action'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // TextField for vehicle situation.
                    TextField(
                      controller: _vehicleSituationController,
                      decoration: InputDecoration(
                        labelText: 'Current Vehicle Situation',
                        hintText: 'Describe the situation of your vehicle',
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 10),
                    // Display checkboxes for common vehicle problems.
                    Column(
                      children: vehicleProblems.keys.map((problem) {
                        return CheckboxListTile(
                          title: Text(problem),
                          value: vehicleProblems[problem],
                          onChanged: (bool? value) {
                            setState(() {
                              vehicleProblems[problem] = value!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    // "Advance pay" button.
                    ElevatedButton.icon(
                      onPressed: () {
                        _payWithRazorpay(workshop);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.payments),
                      label: Text('Pay Advance'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 50, 78, 104),
        title: Text(
          'Available Workshops',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: TextField(
                onChanged: (text) {
                  setState(() {
                    enteredLocation = text;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Search for a location',
                  prefixIcon: Icon(Icons.search,
                      color: const Color.fromARGB(255, 52, 121, 177)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 255, 255, 255),
                  contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                ),
              ),
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _getWorkshops(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No active workshops available.'));
                } else {
                  List<Map<String, dynamic>> workshops = snapshot.data!;
                  final filteredWorkshops = getFilteredWorkshops(workshops);

                  return filteredWorkshops.isEmpty
                      ? Center(
                          child: Text(
                              'No workshops found for the entered location.'))
                      : Expanded(
                          child: ListView.builder(
                            itemCount: filteredWorkshops.length,
                            itemBuilder: (context, index) {
                              var workshop = filteredWorkshops[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  elevation: 8,
                                  shadowColor:
                                      Colors.deepPurple.withOpacity(0.2),
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              const Color.fromARGB(
                                                  255, 33, 93, 128),
                                              const Color.fromARGB(
                                                  255, 116, 29, 29)
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    child: Image.network(
                                                      workshop['companyLogo'],
                                                      width: 80,
                                                      height: 80,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          workshop[
                                                              'companyName'],
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: const Color
                                                                .fromARGB(255,
                                                                244, 172, 113),
                                                          ),
                                                        ),
                                                        SizedBox(height: 8),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.location_on,
                                                              color: const Color
                                                                  .fromARGB(
                                                                  255,
                                                                  122,
                                                                  118,
                                                                  207),
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Expanded(
                                                              child: Text(
                                                                workshop['additionalData']
                                                                        ?[
                                                                        'location_name'] ??
                                                                    'Not Available',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            GestureDetector(
                                                              onTap: () {
                                                                _launchPhone(workshop[
                                                                        'phoneNo'] ??
                                                                    'Not Available');
                                                              },
                                                              child: Icon(
                                                                Icons.phone,
                                                                color: const Color
                                                                    .fromARGB(
                                                                    255,
                                                                    58,
                                                                    202,
                                                                    56),
                                                                size: 18,
                                                              ),
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              workshop[
                                                                      'phoneNo'] ??
                                                                  'Not Available',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 4),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.car_repair,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                            SizedBox(width: 8),
                                                            Text(
                                                              workshop[
                                                                      'service'] ??
                                                                  'Not Available',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .white),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 20),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  ElevatedButton.icon(
                                                    onPressed: () =>
                                                        _showLocationAndPaymentDialog(
                                                            workshop),
                                                    icon: Icon(Icons.send,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 150, 142, 67)),
                                                    label: Text('Send Request'),
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              FeedbackScreen(
                                                            stationId:
                                                                workshop['id'],
                                                            stationName: workshop[
                                                                'companyName'],
                                                            service: 'repair',
                                                            userId: FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                ?.uid,
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                    icon: Icon(Icons.feedback,
                                                        color: const Color
                                                            .fromARGB(
                                                            255, 83, 56, 46)),
                                                    label: Text('Feedback'),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
