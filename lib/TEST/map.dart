import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const MapSelectionApp());
}

class MapSelectionApp extends StatelessWidget {
  const MapSelectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Select and Save Location',
      home: MapSelectionPage(
        onLocationSelected: (LatLng selectedLocation) {
          // Callback that receives selected coordinates
          print(
              'Returned Coordinates: Latitude = ${selectedLocation.latitude}, Longitude = ${selectedLocation.longitude}');
        },
      ),
    );
  }
}

class MapSelectionPage extends StatefulWidget {
  final void Function(LatLng selectedLocation) onLocationSelected;

  const MapSelectionPage({super.key, required this.onLocationSelected});

  @override
  State<MapSelectionPage> createState() => _MapSelectionPageState();
}

class _MapSelectionPageState extends State<MapSelectionPage> {
  LatLng? _selectedLocation; // Store selected coordinates

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Location'),
      ),
      body: Column(
        children: [
          // Map Section
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: const LatLng(10.8505, 76.2711), // Kerala, India
                initialZoom: 7.0,
                onTap: (TapPosition tapPosition, LatLng point) {
                  setState(() {
                    _selectedLocation = point; // Update selected location
                  });
                  widget.onLocationSelected(
                      point); // Return coordinates via callback
                },
              ),
              children: [
                // Load OpenStreetMap tiles
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: const ['a', 'b', 'c'],
                ),
                // Show marker for selected location
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _selectedLocation!,
                        child: const Icon(
                          Icons.location_pin,
                          size: 40.0,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          // Display selected location
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                if (_selectedLocation != null) ...[
                  // Print coordinates to the console
                  Builder(
                    builder: (context) {
                      print(
                          'Selected Location: Latitude = ${_selectedLocation!.latitude}, Longitude = ${_selectedLocation!.longitude}');
                      return Text(
                        'Selected Location: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
