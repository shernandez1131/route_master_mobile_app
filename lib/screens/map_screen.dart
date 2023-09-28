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
  Set<Polyline> polylines = {};
  List<dynamic> _allRoutes = [];
  int _currentRouteIndex = 0;
  String _currentRouteInfo = "";

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
            polylines: polylines,
          ),
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
                      : const SizedBox(width: 1),
                  (_allRoutes.isNotEmpty)
                      ? GestureDetector(
                          onHorizontalDragEnd: (details) {
                            // Determine if this was a left or right swipe
                            if (details.velocity.pixelsPerSecond.dx > 0) {
                              // Right swipe
                              if (_currentRouteIndex > 0) {
                                _currentRouteIndex--;
                                _displayRoute(_allRoutes[_currentRouteIndex]);
                              }
                            } else if (details.velocity.pixelsPerSecond.dx <
                                0) {
                              // Left swipe
                              if (_currentRouteIndex < _allRoutes.length - 1) {
                                _currentRouteIndex++;
                                _displayRoute(_allRoutes[_currentRouteIndex]);
                              }
                            }
                          },
                          child: Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(Icons.arrow_back_ios,
                                      color: Colors.blue),
                                  Text(_currentRouteInfo),
                                  Icon(Icons.arrow_forward_ios,
                                      color: Colors.blue),
                                ],
                              ),
                            ),
                          ))
                      : const SizedBox(width: 1),
                ],
              ),
            ),
          ),
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
    // Clear existing polylines
    polylines.clear();

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
            color: Colors.blue,
            width: 5,
            points: stepPolylinePoints,
          );
        }

        if (polyline != null) {
          // Ensure polyline has a value before adding
          polylines.add(polyline);
        }
      }
    }

    // Update the route info in the bottom popup/container
    String? transitLineName =
        getFirstTransitLineName(route['legs'][0]['steps']);
    if (transitLineName != null) {
      setState(() {
        _currentRouteInfo =
            "${route['legs'][0]['duration']['text']} via $transitLineName";
      });
    } else {
      setState(() {
        _currentRouteInfo = "${route['legs'][0]['duration']['text']}";
      });
    }
  }

  String? getFirstTransitLineName(List<dynamic> steps) {
    for (var step in steps) {
      if (step['travel_mode'] == 'TRANSIT' &&
          step.containsKey('transit_details')) {
        return step['transit_details']['line']['short_name'];
      }
    }
    return null;
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
