import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_master_mobile_app/extensions.dart';
import 'package:route_master_mobile_app/models/bus_line_model.dart';
import 'package:route_master_mobile_app/models/bus_stop_model.dart';
import 'package:route_master_mobile_app/services/bus_line_service.dart';

class BusRouteScreen extends StatefulWidget {
  final List<BusStop> busStops;

  const BusRouteScreen({Key? key, required this.busStops}) : super(key: key);

  @override
  State<BusRouteScreen> createState() => _BusRouteScreenState();
}

class _BusRouteScreenState extends State<BusRouteScreen> {
  //GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  BitmapDescriptor? busIcon;
  List<BusLine> busLines = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initBusIcon();
    _showDisclaimer();
  }

  void _initBusIcon() async {
    busIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(100, 100)),
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
          onTap: () async {
            //debugPrint('StopId: ${busStop.busStopId}. Clicked ${busStop.name}');
            // Handle marker tap: show bus stop details, navigate, etc.
            setState(() {
              isLoading = true;
            });
            busLines =
                await BusLineService.getBusLinesByStopId(busStop.busStopId);
            setState(() {
              isLoading = false;
            });
            //Show a dialog with the bus lines
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Líneas de bus'),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: busLines.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Row(
                              children: [
                                busLines[index].logo == ""
                                    ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border: Border.all(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              width: 1,
                                            ),
                                            color: Colors.white,
                                            boxShadow: [
                                              BoxShadow(
                                                color: busLines[index]
                                                    .color
                                                    .toColor(),
                                                spreadRadius: 0,
                                                blurRadius: 0,
                                                offset: const Offset(5, 0),
                                              ),
                                            ]),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0,
                                              right: 4.0,
                                              top: 2.0,
                                              bottom: 2.0),
                                          child: Row(
                                            children: [
                                              const Icon(Icons.directions_bus),
                                              Text(
                                                busLines[index].code,
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Image.memory(
                                        base64Decode(busLines[index].logo!),
                                        width: 36,
                                        height: 36,
                                        scale: 1.5,
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(busLines[index].alias == null
                                      ? '${busLines[index].firstStop} - ${busLines[index].lastStop}'
                                      : '${busLines[index].firstStop} - ${busLines[index].lastStop} [${busLines[index].alias!}]'),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  );
                },
              );
            }
          },
        );
      }).toSet();
    }
  }

  void _showDisclaimer() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Información'),
            content: const Text(
              'Disculpe, esta información puede no ser precisa. Actualmente no disponemos de la información completa de paradas de autobús en Lima. Este es un trabajo en proceso.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.busStops.isNotEmpty
                  ? LatLng(widget.busStops.first.latitude,
                      widget.busStops.first.longitude)
                  : const LatLng(-12.0461513,
                      -77.0306332), // Default to center if no bus stops found
              zoom: 12,
            ),
            markers: _markers,
          ),
          isLoading
              ? Container(
                  color: Colors.black
                      .withOpacity(0.5), // Semi-transparent background
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink(),
          Positioned(
            top: 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
