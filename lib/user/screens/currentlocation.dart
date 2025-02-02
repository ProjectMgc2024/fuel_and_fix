import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fuel_and_fix/user/screens/repair.dart';
import 'package:fuel_and_fix/user/screens/tow.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class FetchLocationPopup extends StatefulWidget {
  final String serviceType; // 'Repair' or 'Tow'

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

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (!mounted) return;

      setState(() {
        _currentPosition = position;
      });

      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        setState(() {
          _currentLocationName =
              "${place.locality}, ${place.administrativeArea}, ${place.country}";
          _locationFetched = true;
        });

        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(user.uid)
              .update({
            'additionalData.latitude': position.latitude,
            'additionalData.longitude': position.longitude,
            'additionalData.location_name': _currentLocationName,
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
      onWillPop: () async {
        return false;
      },
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
                      ],
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
