import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'dart:convert';

void main() {
  runApp(const LocationTrackingApp());
}

class LocationTrackingApp extends StatelessWidget {
  const LocationTrackingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MapmyIndia Location Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LocationTrackingScreen(),
    );
  }
}

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  // MapmyIndia credentials
  static const String mapmyIndiaApiKey = '78c2774d6a89995996f4cbf853b7268f';
  static const String clientId =
      '96dHZVzsAuuf6ztgSSbKsOyHlwn6dlFVOyaw25JY2bi_GlaBIJvdzfPNcLjb_TYxzh96D8uRirxApGi-lRQTJw==';
  static const String clientSecret =
      'lrFxI-iSEg9YzB8YZd4GBCf9hm9bHBvEnCtYLQjGrHBUOfIeF3SdM4dte6NLmkVMfzKJEDAxlUacfFl8MCwSWO3jA43rYvma';

  LatLng? _currentLocation;
  LatLng? _inputLocation;

  final TextEditingController _locationController = TextEditingController();
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Fetch user's current GPS location
  Future<void> _getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    var userLocation = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(userLocation.latitude!, userLocation.longitude!);
      _mapController.move(_currentLocation!, 15.0);
    });
  }

  // Fetch access token from MapmyIndia
  Future<String?> _getAccessToken() async {
    final response = await http.post(
      Uri.parse('https://outpost.mapmyindia.com/api/security/oauth/token'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'grant_type': 'client_credentials',
        'client_id': clientId,
        'client_secret': clientSecret,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      debugPrint('Failed to get access token: ${response.body}');
      return null;
    }
  }

  // Geocode input location to LatLng
  Future<void> _searchLocation() async {
    final input = _locationController.text.trim();
    if (input.isEmpty) return;

    final accessToken = await _getAccessToken();
    if (accessToken == null) {
      debugPrint("Failed to retrieve access token.");
      return;
    }

    final url =
        'https://atlas.mapmyindia.com/api/places/geocode?address=$input';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['copResults'] != null && data['copResults'].isNotEmpty) {
          final lat = double.tryParse(data['copResults'][0]['latitude'] ?? '');
          final lng = double.tryParse(data['copResults'][0]['longitude'] ?? '');

          if (lat != null && lng != null) {
            setState(() {
              _inputLocation = LatLng(lat, lng);
              _mapController.move(_inputLocation!, 15.0);
            });
          } else {
            debugPrint('Latitude or longitude is null or invalid.');
          }
        } else {
          debugPrint('No results found for the input location.');
        }
      } else {
        debugPrint('Error fetching location: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MapmyIndia Location Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      hintText: 'Enter location (e.g., New Delhi)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _searchLocation,
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentLocation ?? LatLng(28.6139, 77.2090),
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://apis.mapmyindia.com/advancedmaps/v1/$mapmyIndiaApiKey/xyz/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.mapmyindia',
                  additionalOptions: const {'User-Agent': 'flutter_map_app'},
                ),
                MarkerLayer(
                  markers: [
                    if (_currentLocation != null)
                      Marker(
                        point: _currentLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.blue, size: 30),
                      ),
                    if (_inputLocation != null)
                      Marker(
                        point: _inputLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(Icons.location_on,
                            color: Colors.red, size: 30),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
