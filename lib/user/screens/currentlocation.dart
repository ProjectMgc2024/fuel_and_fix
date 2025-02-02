import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/owner/screens/fuel/fuel_request.dart';
import 'package:fuel_and_fix/user/screens/repair.dart';
import 'package:fuel_and_fix/user/screens/tow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class FetchLocationPopup extends StatefulWidget {
  final String serviceType; // e.g., 'Repair', 'Tow', or 'Fuel'

  FetchLocationPopup({required this.serviceType});

  @override
  _FetchLocationPopupState createState() => _FetchLocationPopupState();
}

class _FetchLocationPopupState extends State<FetchLocationPopup> {
  bool _isFetchingLocation = false;
  String? _currentLocationName;
  Position? _currentPosition;
  bool _locationFetched = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      // Check location permissions.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception("Location permissions are denied");
        }
      }

      // Get the current position with high accuracy.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
      });

      // Reverse-geocode to obtain a human-readable address.
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String locationName =
            "${place.locality}, ${place.administrativeArea}, ${place.country}";
        setState(() {
          _currentLocationName = locationName;
          _locationFetched = true;
        });

        // Update user document in Firestore with current location details
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .update({
            'additionalData': {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'location_name': locationName,
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch location: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  void _navigateToServiceScreen() {
    if (_locationFetched) {
      Navigator.pop(context); // Close the popup

      if (widget.serviceType == 'Repair') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WorkshopScreen(),
          ),
        );
      } else if (widget.serviceType == 'Tow') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TowingServiceCategories(),
          ),
        );
      } else if (widget.serviceType == 'Fuel') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FuelFillingRequest(),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please wait until the location is fetched.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Location",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _isFetchingLocation
                  ? Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Fetching location..."),
                      ],
                    )
                  : Column(
                      children: [
                        Icon(Icons.location_on,
                            size: 50, color: Colors.deepPurple),
                        SizedBox(height: 10),
                        Text(
                          _currentLocationName ?? "Location not available",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _navigateToServiceScreen,
                          child: Text("Go to ${widget.serviceType} Services"),
                        ),
                        // Retry button if location is not yet fetched.
                        if (!_locationFetched)
                          TextButton(
                            onPressed: _getCurrentLocation,
                            child: Text("Retry"),
                          ),
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
