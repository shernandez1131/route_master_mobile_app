import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
//import 'package:route_master_mobile_app/widgets/search_widget.dart';
import '../constants.dart';
import 'profile_screen.dart';

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

    // Update the markers set
    setState(() {
      if (type == 'start') {
        markers.remove(MarkerId('startMarker')); // Remove previous start marker
      } else {
        markers
            .remove(MarkerId('finishMarker')); // Remove previous finish marker
      }
      markers.add(marker); // Add the new marker

      // Adjust the camera position to show both markers if there are two markers
      if (markers.length == 2) {
        LatLngBounds bounds = LatLngBounds(
          southwest: LatLng(
            markers.elementAt(0).position.latitude,
            markers.elementAt(0).position.longitude,
          ),
          northeast: LatLng(
            markers.elementAt(1).position.latitude,
            markers.elementAt(1).position.longitude,
          ),
        );
        mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
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
}
