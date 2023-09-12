import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController mapController;
  TextEditingController _locationController = TextEditingController();

  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-12.0461513, -77.0306332),
    zoom: 11,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8),
              child: TextField(
                controller: _locationController,
                decoration: InputDecoration(hintText: 'Search location'),
              ),
            ),
            Expanded(
              child: GoogleMap(
                initialCameraPosition: _initialCameraPosition,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.directions),
            label: 'Directions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Lines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.stop),
            label: 'Stops',
          ),
        ],
      ),
    );
  }
}
