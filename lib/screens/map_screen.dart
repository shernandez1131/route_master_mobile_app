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

  final CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(-12.0461513, -77.0306332),
    zoom: 11,
  );

  final FocusNode searchBoxFocusNode = FocusNode();

  @override
  void initState() {
    searchBoxFocusNode.addListener(() {
      if (searchBoxFocusNode.hasFocus) {
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
                  Row(
                    children: [
                      !searchBoxFocusNode.hasFocus
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: Focus(
                          focusNode: searchBoxFocusNode,
                          child: AppBarPlacesAutoCompleteTextField(
                            textDecoration: InputDecoration(
                              hintText: '¿A dónde te diriges?',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(32),
                              ),
                              filled: true, // Fill the background
                              fillColor: Colors.white,
                            ),
                            textStyle: null,
                            cursorColor: null,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: PlacesAutocompleteResult(
                      onTap: (p) =>
                          displayPrediction(p, ScaffoldMessenger.of(context)),
                      logo: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [FlutterLogo()],
                      ),
                      resultTextStyle: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
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

  @override
  void onResponseError(PlacesAutocompleteResponse response) {
    super.onResponseError(response);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(response.errorMessage ?? 'Unknown error')),
    );
  }

  @override
  void onResponse(PlacesAutocompleteResponse response) {
    super.onResponse(response);

    if (response.predictions.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Got answer')),
      );
    }
  }
}

Future<void> displayPrediction(
    Prediction? p, ScaffoldMessengerState messengerState) async {
  if (p == null) {
    return;
  }

  // get detail (lat/lng)
  final _places = GoogleMapsPlaces(
    apiKey: kGoogleApiKey,
    apiHeaders: await const GoogleApiHeaders().getHeaders(),
  );

  final detail = await _places.getDetailsByPlaceId(p.placeId!);
  final geometry = detail.result.geometry!;
  final lat = geometry.location.lat;
  final lng = geometry.location.lng;

  messengerState.showSnackBar(
    SnackBar(
      content: Text('${p.description} - $lat/$lng'),
    ),
  );
}
