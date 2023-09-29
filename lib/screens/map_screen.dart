import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_master_mobile_app/services/directions_service.dart';
import 'package:uuid/uuid.dart';
//import 'package:route_master_mobile_app/widgets/search_widget.dart';
import '../constants.dart';
import 'profile_screen.dart';

final DirectionsService directionsService = DirectionsService(kGoogleApiKey);

class MapScreen extends PlacesAutocompleteWidget {
  MapScreen({Key? key})
      : super(
          key: key,
          apiKey: kGoogleApiKey,
          sessionToken: const Uuid().v4(),
          language: 'es-419',
          components: [const Component(Component.country, 'pe')],
        );

  @override
  PlacesAutocompleteState createState() => _MapScreenState();
}

class _MapScreenState extends PlacesAutocompleteState {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Map<Polyline, dynamic> polylines = {};
  List<dynamic> _allRoutes = [];
  List<String> _currentRouteInfo = [];
  int _currentRouteIndex = 0;

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(-12.0461513, -77.0306332),
    zoom: 11,
  );

  final FocusNode searchBoxFocusNode = FocusNode();
  final FocusNode searchBoxStartingPointFocusNode = FocusNode();
  List<Prediction> predictions = []; // List to store predictions

  @override
  void initState() {
    searchBoxFocusNode.addListener(() {
      if (searchBoxFocusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
    searchBoxStartingPointFocusNode.addListener(() {
      if (searchBoxStartingPointFocusNode.hasFocus) {
        setState(() {});
      } else {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
              markers: markers,
              polylines: polylines.keys.toSet(),
              onTap: (LatLng tappedPoint) {
                const threshold = 1.0; // Adjust this value based on your needs
                double? closestDistance;
                Map<dynamic, dynamic>? closestStep;

                for (var polyline in polylines.keys) {
                  for (var point in polyline.points) {
                    if (polylines[polyline]['travel_mode'] == 'TRANSIT') {
                      double currentDistance =
                          _distanceBetween(tappedPoint, point);

                      // Check if this distance is the smallest found so far
                      if (closestDistance == null ||
                          currentDistance < closestDistance) {
                        closestDistance = currentDistance;
                        closestStep = polylines[polyline];
                      }
                    }
                  }
                }

                // After looping, check if the closestDistance is within the threshold
                if (closestDistance != null && closestDistance < threshold) {
                  // Assuming `transit_details` contains required info, adjust as necessary
                  var timeToBusStop = (closestStep!['duration']['value'] / 60)
                      .round(); // Convert to minutes
                  var headway = closestStep['transit_details']['headway'] ??
                      10; // Use a default if not provided
                  var busName = closestStep['transit_details']['line']['name'];
                  var busShortName =
                      closestStep['transit_details']['line']['short_name'];

                  showBusDeparturePopup(
                      context, timeToBusStop, headway, busName, busShortName);
                }
              }),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.transparent, // Transparent background
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          (!searchBoxFocusNode.hasFocus &&
                                  !searchBoxStartingPointFocusNode.hasFocus)
                              ? GestureDetector(
                                  onTap: () {
                                    // Handle profile icon click, navigate to profile_view
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const ProfileScreen()),
                                    );
                                  },
                                  child: const CircleAvatar(
                                    radius: 20, // Adjust the size as needed
                                    backgroundImage:
                                        AssetImage('images/profile_icon.png'),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          (!searchBoxFocusNode.hasFocus &&
                                  !searchBoxStartingPointFocusNode.hasFocus)
                              ? const SizedBox(width: 12)
                              : const SizedBox(width: 0),
                          !searchBoxFocusNode.hasFocus
                              ? Expanded(
                                  child: Focus(
                                    focusNode: searchBoxStartingPointFocusNode,
                                    child: AppBarPlacesAutoCompleteTextField(
                                        textDecoration: InputDecoration(
                                          hintText:
                                              '¿Cuál es tu punto de partida?',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(32),
                                          ),
                                          filled: true, // Fill the background
                                          fillColor: Colors.white,
                                        ),
                                        textStyle: null,
                                        cursorColor: null),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                      (!searchBoxStartingPointFocusNode.hasFocus)
                          ? Focus(
                              focusNode: searchBoxFocusNode,
                              child: AppBarPlacesAutoCompleteTextFieldAlt(
                                  textDecoration: InputDecoration(
                                    hintText: '¿Cuál es tu punto de llegada?',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    filled: true, // Fill the background
                                    fillColor: Colors.white,
                                  ),
                                  textStyle: null,
                                  cursorColor: null))
                          : const SizedBox.shrink(),
                    ],
                  ),
                  (searchBoxStartingPointFocusNode.hasFocus)
                      ? Expanded(
                          child: Container(
                            color: Colors.white.withOpacity(0.7),
                            height: 100, // White background
                            child: PlacesAutocompleteResult(
                              onTap: (prediction) {
                                displayPrediction(prediction, 'start');
                              },
                              logo: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [FlutterLogo()],
                              ),
                              resultTextStyle:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        )
                      : const SizedBox(width: 1),
                  (searchBoxFocusNode.hasFocus)
                      ? Expanded(
                          child: Container(
                            color: Colors.white.withOpacity(0.7),
                            height: 100, // White background
                            child: PlacesAutocompleteResultAlt(
                              onTap: (prediction) {
                                displayPrediction(prediction, 'finish');
                              },
                              logo: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [FlutterLogo()],
                              ),
                              resultTextStyle:
                                  Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        )
                      : const SizedBox(width: 1)
                ],
              ),
            ),
          ),
          (_allRoutes.isNotEmpty &&
                  !searchBoxFocusNode.hasFocus &&
                  !searchBoxStartingPointFocusNode.hasFocus)
              ? Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      // Determine if this was a left or right swipe
                      if (details.velocity.pixelsPerSecond.dx > 0) {
                        // Right swipe
                        _routeSwipeRight();
                      } else if (details.velocity.pixelsPerSecond.dx < 0) {
                        // Left swipe
                        _routeSwipeLeft();
                      }
                    },
                    child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                              )
                            ]),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _routeSwipeRight();
                              },
                              child: Icon(Icons.arrow_back_ios,
                                  color: Colors.blue),
                            ),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment
                                    .start, // Aligns text to the start
                                children: [
                                  ..._currentRouteInfo
                                      .map((info) => Text(info))
                                      .toList(),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _routeSwipeLeft();
                              },
                              child: Icon(Icons.arrow_forward_ios,
                                  color: Colors.blue),
                            ),
                          ],
                        )),
                  ),
                )
              : const SizedBox(width: 1),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
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

  void _routeSwipeRight() {
    if (_currentRouteIndex > 0) {
      _currentRouteIndex--;
    } else {
      _currentRouteIndex = _allRoutes.length - 1;
    }
    _displayRoute(_allRoutes[_currentRouteIndex]);
  }

  void _routeSwipeLeft() {
    if (_currentRouteIndex < _allRoutes.length - 1) {
      _currentRouteIndex++;
    } else {
      _currentRouteIndex = 0;
    }
    _displayRoute(_allRoutes[_currentRouteIndex]);
  }

  Future<void> fetchAndDisplayDirections(
      LatLng origin, LatLng destination) async {
    try {
      final directions = await directionsService.getDirections(
        origin: origin,
        destination: destination,
      );

      if (directions != null && directions['routes'] != null) {
        List<dynamic> routes = directions['routes'];

        // Sort routes based on travel time
        routes.sort((a, b) {
          int timeA = a['legs'][0]['duration']['value'];
          int timeB = b['legs'][0]['duration']['value'];
          return timeA.compareTo(timeB);
        });

        // Store all routes for swipe navigation
        _allRoutes = routes;
        _currentRouteIndex = 0; // Start with the quickest route

        // Initially, display the quickest route
        _displayRoute(routes[0]);
      }
    } catch (e) {
      // Handle errors
      print(e);
    }
  }

  void _displayRoute(dynamic route) {
    polylines.clear();

    List<Color> busColors = [
      Colors.green,
      Colors.deepPurple.shade600,
      Colors.orange.shade800,
      Colors.purpleAccent,
      Colors.teal.shade900,
      Colors.brown,
      Colors.cyan.shade600
    ];

    int currentBusColorIndex = 0;

    for (var leg in route['legs']) {
      for (var step in leg['steps']) {
        // Decode the polyline for this step
        String stepPoints = step['polyline']['points'];
        List<LatLng> stepPolylinePoints =
            _convertToLatLng(_decodePoly(stepPoints));

        Polyline? polyline; // Make it nullable

        // Check travel mode
        if (step['travel_mode'] == 'WALKING') {
          polyline = Polyline(
            polylineId: PolylineId('step${step['start_location']}'),
            color: Colors.blue,
            width: 5,
            points: stepPolylinePoints,
            patterns: [
              PatternItem.dash(10),
              PatternItem.gap(10)
            ], // Dotted pattern
          );
        } else if (step['travel_mode'] == 'TRANSIT') {
          polyline = Polyline(
            polylineId: PolylineId('step${step['start_location']}'),
            color: busColors[currentBusColorIndex %
                busColors
                    .length], // Use modulo to loop back to the start if there are more buses than colors
            width: 5,
            points: stepPolylinePoints,
          );
          currentBusColorIndex++; // Move to the next color for the next bus
        }

        if (polyline != null) {
          // Associate polyline with its step data
          polylines[polyline] = step;
        }
      }
    }

    // Update the route info in the bottom popup/container
    List<String> routeInfo = [];
    for (var leg in route['legs']) {
      for (var step in leg['steps']) {
        String instruction = step['html_instructions'];

        // Optionally: Strip HTML tags
        instruction = instruction.replaceAll(RegExp('<[^>]+>'), '');

        // Check if this step is a transit step and has line information
        if (step['travel_mode'] == 'TRANSIT' &&
            step.containsKey('transit_details')) {
          String? lineName = step['transit_details']['line']['short_name'] ??
              step['transit_details']['line']['name'];
          if (lineName != null) {
            instruction += " (vía $lineName)";
          }
        }

        routeInfo.add("${step['duration']['text']} - $instruction");
      }
    }

    setState(() {
      _currentRouteInfo = routeInfo;
    });
  }

  Future<void> displayPrediction(Prediction? p, String type) async {
    if (p == null) {
      return;
    }

    updateTextField(p, type);
    // Get detail (lat/lng)
    final _places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    final detail = await _places.getDetailsByPlaceId(p.placeId!);
    final geometry = detail.result.geometry!;
    final lat = geometry.location.lat;
    final lng = geometry.location.lng;

    // Create a LatLng object from the coordinates
    final targetLocation = LatLng(lat, lng);

    // Create a Marker object
    final MarkerId markerId =
        type == 'start' ? MarkerId('startMarker') : MarkerId('finishMarker');
    final BitmapDescriptor markerIcon = type == 'start'
        ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
        : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet);

    final marker = Marker(
      markerId: markerId,
      position: targetLocation,
      infoWindow: InfoWindow(
        title: p.description ?? '',
        snippet: '$lat/$lng',
      ),
      icon: markerIcon,
    );

    markers
        .removeWhere((existingMarker) => existingMarker.markerId == markerId);

    // Update the markers set
    setState(() {
      markers.add(marker); // Add the new marker

      if (markers.length == 2) {
        // Create LatLngBounds based on all markers
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            markers
                .map((marker) => marker.position.latitude)
                .reduce((min, value) => min < value ? min : value),
            markers
                .map((marker) => marker.position.longitude)
                .reduce((min, value) => min < value ? min : value),
          ),
          northeast: LatLng(
            markers
                .map((marker) => marker.position.latitude)
                .reduce((max, value) => max > value ? max : value),
            markers
                .map((marker) => marker.position.longitude)
                .reduce((max, value) => max > value ? max : value),
          ),
        );

        // Adjust the camera position to show all markers
        mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 110));

        LatLng? originCoords;
        LatLng? destinationCoords;

        // Find the origin and destination coordinates from the markers
        markers.forEach((marker) {
          if (marker.markerId.value == 'startMarker') {
            originCoords = marker.position;
          } else if (marker.markerId.value == 'finishMarker') {
            destinationCoords = marker.position;
          }
        });

        // Check if both origin and destination coordinates are available
        if (originCoords != null && destinationCoords != null) {
          // Call the fetchAndDisplayDirections function with the coordinates
          fetchAndDisplayDirections(originCoords!, destinationCoords!);
        }
      } else {
        // If there's only one marker, zoom in on that marker
        mapController
            .animateCamera(CameraUpdate.newLatLngZoom(targetLocation, 15.0));
      }

      // Unfocus text fields
      searchBoxFocusNode.unfocus();
      searchBoxStartingPointFocusNode.unfocus();
    });
  }

  void showBusDeparturePopup(BuildContext context, int timeToBusStop,
      int headway, String busName, String busShortName) {
    // Calculate future departure times
    DateTime now = DateTime.now();
    DateTime firstDepartureTime = now.add(Duration(minutes: timeToBusStop));

    List<DateTime> departureTimes = List.generate(5, (index) {
      return firstDepartureTime.add(Duration(seconds: headway * index));
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Bus $busShortName: $busName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...departureTimes.map((time) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("${time.hour}:${time.minute}"),
                  // child: Divider(
                  //   child: Text("${time.hour}:${time.minute}"),
                  // ),
                );
              }).toList(),
              SizedBox(height: 10),
              TextButton(
                child: const Text("Iniciar Viaje"),
                onPressed: () {
                  // Handle button press
                },
                // decoration: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(20.0),
                // ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _distanceBetween(LatLng a, LatLng b) {
    var p = 0.017453292519943295;
    var c = cos;
    var a1 = 0.5 -
        c((b.latitude - a.latitude) * p) / 2 +
        c(a.latitude * p) *
            c(b.latitude * p) *
            (1 - c((b.longitude - a.longitude) * p)) /
            2;
    var distance = 12742 * asin(sqrt(a1));
    return distance;
  }

  List<LatLng> _convertToLatLng(List points) {
    List<LatLng> result = <LatLng>[];
    for (int i = 0; i < points.length; i++) {
      if (i % 2 != 0) {
        result.add(LatLng(points[i - 1], points[i]));
      }
    }
    return result;
  }

  List _decodePoly(String encoded) {
    List poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add((lat / 1E5));
      poly.add((lng / 1E5));
    }
    return poly;
  }
}
