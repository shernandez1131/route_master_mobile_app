import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_master_mobile_app/models/bus_stop_model.dart';

class BusRouteScreen extends StatefulWidget {
  final List<BusStop> busStops;

  const BusRouteScreen({Key? key, required this.busStops}) : super(key: key);

  @override
  _BusRouteScreenState createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? busIcon;

  @override
  void initState() {
    super.initState();
    _initBusIcon();
    _showDisclaimer();
  }

  void _initBusIcon() async {
    busIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(100, 100)),
      'images/bus_stop_icon.png',
    );
    setState(() {
      _setMarkers();
    });
  }

  void _setMarkers() {
    if (widget.busStops.isNotEmpty) {
      _markers = widget.busStops.map((busStop) {
        return Marker(
          markerId: MarkerId(busStop.name),
          position: LatLng(busStop.latitude, busStop.longitude),
          icon: BitmapDescriptor.defaultMarker,
          infoWindow: InfoWindow(title: busStop.name),
          onTap: () {
            print('Clicked ${busStop.name}');
            // Handle marker tap: show bus stop details, navigate, etc.
          },
        );
      }).toSet();
    }
  }

  void _showDisclaimer() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Información'),
            content: Text(
              'Disculpe, esta información puede no ser precisa. Actualmente no disponemos de la información completa de paradas de autobús en Lima. Este es un trabajo en proceso.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: widget.busStops.isNotEmpty
              ? LatLng(widget.busStops.first.latitude,
                  widget.busStops.first.longitude)
              : LatLng(-12.0461513,
                  -77.0306332), // Default to center if no bus stops found
          zoom: 12,
        ),
        markers: _markers,
      ),
    );
  }
}
