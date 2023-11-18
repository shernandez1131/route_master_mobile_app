import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:route_master_mobile_app/models/models.dart';
import 'package:route_master_mobile_app/screens/qr_scanner.dart';
import 'package:route_master_mobile_app/services/rating_service.dart';
import 'package:route_master_mobile_app/services/trip_service.dart';
import 'package:uuid/uuid.dart';
import '../constants.dart';
import '../services/services.dart';

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
  late LatLng _currentLocation = const LatLng(-12.0461513, -77.0306332);
  Set<Marker> markers = {};
  Map<Polyline, dynamic> polylines = {};
  List<dynamic> _allRoutes = [];
  List<String> _currentRouteInfo = [];
  List<Map<String, dynamic>> routePreviewInfo = [];
  int _currentRouteIndex = 0;
  bool isJourneyStarted = false;
  int finalBusStopsNotified = 0;
  double currentSpeed = 0.0;
  double lastDistance = 0.0;
  DateTime? lastTime;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 1,
  );
  late StreamSubscription<Position> positionStream;
  final FocusNode searchBoxFocusNode = FocusNode();
  final FocusNode searchBoxStartingPointFocusNode = FocusNode();
  List<Prediction> predictions = [];
  dynamic currentRoute;
  late List<FinalBusStop> finalStopsList = [];
  late List<BusLine> busLinesList = [];
  late List<BusStop> busStopsList = [];
  late List<TripDetail> currentRouteBusDetails = [];
  late List<String> currentRouteBusNames = [];
  late Map<String, Map<String, dynamic>> codeMapping = {};
  late Trip currentTrip;
  var allPolylines = [];
  late FinalBusStop paidBusFinalStop;
  late Passenger? currentPassenger;
  bool isPaidTrip = false;
  bool enableFinishJourneyBtn = false;
  //final GlobalKey _modelScaffoldKey = GlobalKey();

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
    _determinePosition().then((value) {
      _currentLocation = LatLng(value.latitude, value.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(_currentLocation));
    });
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        LatLng newLocation = LatLng(position.latitude, position.longitude);

        double distance = _distanceBetween(_currentLocation, newLocation);
        DateTime currentTime = DateTime.now();

        // Calculate time elapsed since the last update
        Duration timeDiff = lastTime != null
            ? currentTime.difference(lastTime!)
            : Duration.zero;

        // Calculate speed if enough time has passed and distance is significant
        if (timeDiff.inSeconds > 0 && distance - lastDistance > 0.001) {
          currentSpeed = (distance - lastDistance) /
              timeDiff.inSeconds; // Speed in meters per second
        }

        // Update values for the next iteration
        lastDistance = distance;
        lastTime = currentTime;
        debugPrint(
            "Speed: ${currentSpeed * 3600} km/s | ${currentSpeed * 1000} m/s");
        setState(() {
          _currentLocation = newLocation;
        });
        // Check proximity to stops
        const double proximityThreshold = 0.3; // Adjust this value as needed
        for (var stopLocation in finalStopsList) {
          double distanceToStop =
              _distanceBetween(_currentLocation, stopLocation.coordinates);

          if (distanceToStop <= proximityThreshold &&
              finalBusStopsNotified == stopLocation.order) {
            // User is close to a stop; show a notification
            _showProximityNotification();
            finalBusStopsNotified += 1;
          }
        }
        if (isPaidTrip) {
          double distanceToStop =
              _distanceBetween(_currentLocation, paidBusFinalStop.coordinates);
          if (distanceToStop < 0.2) {
            enableFinishJourneyBtn = true;
          }
        }
      }
    });
    fetchBusLines().then((data) {
      fetchBusStops().then((response) {
        setState(() {
          busStopsList = response;
          busLinesList = data;

          // Populate codeMapping with additional properties from busLinesList
          for (var busLine in busLinesList) {
            codeMapping[busLine.oldCode] = {
              'newCode': busLine.code,
              'alias': busLine.alias ?? "",
              'color': busLine.color,
              'lineId': busLine.lineId,
            };
          }
        });
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    searchBoxFocusNode.dispose();
    searchBoxStartingPointFocusNode.dispose();
    positionStream.cancel();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
            },
            myLocationEnabled: true, // Blue dot
            myLocationButtonEnabled: false,
            compassEnabled: false, // Compass
            zoomControlsEnabled: false,
            initialCameraPosition: CameraPosition(
              target: _currentLocation,
              zoom: 15.0,
            ),
            markers: markers,
            polylines: polylines.keys.toSet(),
            onTap: (LatLng tappedPoint) {
              const threshold = 0.2; // Adjust this value based on your needs
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
                var headway = closestStep['transit_details']['headway'];
                dynamic arrivalTime;
                if (headway == null) {
                  arrivalTime =
                      closestStep['transit_details']['arrival_time']['text'];
                  // Assuming the structure is like this. Adjust as needed.
                }
                var busName =
                    closestStep['transit_details']['line']['name'] ?? "";
                var busShortName =
                    closestStep['transit_details']['line']['short_name'];

                showBusDeparturePopup(context, timeToBusStop, headway,
                    arrivalTime, busName, busShortName);
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
              child: !isJourneyStarted
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                (!searchBoxFocusNode.hasFocus &&
                                        !searchBoxStartingPointFocusNode
                                            .hasFocus)
                                    ? const SizedBox.shrink()
                                    : const SizedBox.shrink(),
                                (!searchBoxFocusNode.hasFocus &&
                                        !searchBoxStartingPointFocusNode
                                            .hasFocus)
                                    ? const SizedBox(width: 0)
                                    : const SizedBox(width: 0),
                                !searchBoxFocusNode.hasFocus
                                    ? Expanded(
                                        child: Focus(
                                          focusNode:
                                              searchBoxStartingPointFocusNode,
                                          child: AppBarPlacesAutoCompleteTextField(
                                              textDecoration: null,
                                              textStyle: null,
                                              cursorColor: null,
                                              isFocused:
                                                  searchBoxStartingPointFocusNode
                                                      .hasFocus),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                            (!searchBoxStartingPointFocusNode.hasFocus)
                                ? Focus(
                                    focusNode: searchBoxFocusNode,
                                    child: AppBarPlacesAutoCompleteTextFieldAlt(
                                      textDecoration: null,
                                      textStyle: null,
                                      cursorColor: null,
                                      isFocused: searchBoxFocusNode.hasFocus,
                                    ))
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [FlutterLogo()],
                                    ),
                                    resultTextStyle:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                              )
                            : const SizedBox(width: 1)
                      ],
                    )
                  : FractionallySizedBox(
                      widthFactor: 1,
                      child: isPaidTrip
                          ? ElevatedButton(
                              onPressed: () {
                                if (enableFinishJourneyBtn) {
                                  _finishPaidJourney();
                                }
                              },
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  isPaidTrip && !enableFinishJourneyBtn
                                      ? Colors.grey
                                      : Colors.red,
                                ),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                              child: (paidBusFinalStop.order ==
                                      finalStopsList.length - 1)
                                  ? Text(
                                      "Pagar Bus ${paidBusFinalStop.busLineName} y finalizar viaje")
                                  : Text(
                                      "Pagar Bus ${paidBusFinalStop.busLineName}"),
                            )
                          : ElevatedButton(
                              onPressed: _finishJourney,
                              style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.red),
                                foregroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.white),
                              ),
                              child: const Text("Finalizar Viaje"),
                            ),
                    )),
        ),
        (_allRoutes.isNotEmpty &&
                !searchBoxFocusNode.hasFocus &&
                !searchBoxStartingPointFocusNode.hasFocus)
            ? Positioned(
                bottom: 66,
                left: 16,
                right: 16,
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (!isJourneyStarted)
                            ? GestureDetector(
                                onTap: () {
                                  _routeSwipeRight();
                                },
                                child: const Icon(Icons.arrow_back_ios,
                                    color: Colors.blue),
                              )
                            : const SizedBox(width: 1),
                        Flexible(
                          child: !isJourneyStarted
                              ? Column(
                                  children: [
                                    Text(
                                        "${_currentRouteIndex + 1}/${_allRoutes.length}"),
                                    SingleChildScrollView(
                                        scrollDirection: Axis
                                            .horizontal, // Allow horizontal scrolling
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: routePreviewInfo
                                              .asMap()
                                              .entries
                                              .expand((entry) {
                                            int idx = entry.key;
                                            var info = entry.value;
                                            List<Widget> widgets = [];

                                            // If not the first element, prepend an arrow
                                            if (idx != 0) {
                                              widgets.add(
                                                  const SizedBox(width: 8));
                                              widgets.add(const Icon(
                                                  Icons.arrow_forward_ios,
                                                  size: 12.0,
                                                  color: Colors
                                                      .grey)); // Arrow icon
                                              widgets.add(const SizedBox(
                                                  width:
                                                      6)); // Provide some spacing
                                            }

                                            // Then add the actual icon or label
                                            if (info['type'] == 'walking') {
                                              widgets.add(Column(
                                                children: [
                                                  const Icon(
                                                      Icons.directions_walk),
                                                  Text(info['duration'])
                                                ],
                                              ));
                                            } else {
                                              widgets.add(Column(
                                                children: [
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      border: Border.all(
                                                        color: Colors.grey
                                                            .withOpacity(0.5),
                                                        width: 1,
                                                      ),
                                                      color: Colors.white,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Color(
                                                              getColorFromHex(
                                                                  info[
                                                                      'color'])),
                                                          spreadRadius: 0,
                                                          blurRadius: 0,
                                                          offset: const Offset(
                                                              5, 0),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 4.0,
                                                        vertical: 2.0,
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            info['short_name'],
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        15),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Text(info['duration'])
                                                ],
                                              ));
                                            }

                                            return widgets;
                                          }).toList(),
                                        )),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ..._currentRouteInfo
                                        .map((info) => Text(info))
                                        .toList(),
                                  ],
                                ),
                        ),
                        (!isJourneyStarted)
                            ? GestureDetector(
                                onTap: () {
                                  _routeSwipeLeft();
                                },
                                child: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.blue),
                              )
                            : const SizedBox(width: 1),
                      ],
                    )),
              )
            : const SizedBox(width: 1),
        (_allRoutes.isNotEmpty &&
                !searchBoxFocusNode.hasFocus &&
                !searchBoxStartingPointFocusNode.hasFocus)
            ? Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: (!isJourneyStarted)
                    ? FractionallySizedBox(
                        widthFactor: 0.6,
                        child: ElevatedButton(
                          onPressed: _startJourney,
                          child: const Center(child: Text("Iniciar Viaje")),
                        ),
                      )
                    : FractionallySizedBox(
                        widthFactor: 0.6,
                        child: ElevatedButton(
                          onPressed: _payForJourney,
                          child: const Center(
                            child: Column(
                              children: [
                                Text("Pagar Pasaje"),
                                Text("Escanear QR"),
                              ],
                            ),
                          ),
                        ),
                      ),
              )
            : const SizedBox(width: 1),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Check if the app has location permissions
          final bool locationPermissionGranted =
              await _checkLocationPermission();

          if (!locationPermissionGranted) {
            // Request location permissions
            await _requestLocationPermission();
          }

          // Check if the location service is enabled on the phone
          final bool locationServiceEnabled =
              await Geolocator.isLocationServiceEnabled();
          if (!locationServiceEnabled && context.mounted) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Servicios de ubicación desactivados'),
                  content: const Text(
                      'Por favor, active los servicios de ubicación en la configuración de su dispositivo para utilizar esta función.'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Cerrar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            // Get the current position to update _currentLocation
            final Position position = await Geolocator.getCurrentPosition();
            setState(() {
              _currentLocation = LatLng(position.latitude, position.longitude);
            });

            // Update the map to the current location
            mapController
                .animateCamera(CameraUpdate.newLatLng(_currentLocation));
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Future<List<BusLine>> fetchBusLines() async {
    return await BusLineService.getBusLines();
  }

  Future<List<BusStop>> fetchBusStops() async {
    return await BusStopService.getBusStops();
  }

  void _showProximityNotification() async {
    NotificationService.showNotification(
      '¡Prepárate para bajar!',
      'Estás cerca de tu parada. Asegúrate de estar listo y no olvides tus pertenencias.',
    );
  }

  Future<bool> _checkLocationPermission() async {
    final locationStatus = await Geolocator.checkPermission();
    return locationStatus == LocationPermission.always ||
        locationStatus == LocationPermission.whileInUse;
  }

  Future<void> _requestLocationPermission() async {
    final locationStatus = await Geolocator.requestPermission();
    if (locationStatus != LocationPermission.always &&
        locationStatus != LocationPermission.whileInUse) {
      // Handle the case where the user denies location permissions
      // You may want to show a message or take appropriate action
    }
  }

  void _routeSwipeRight() {
    if (_currentRouteIndex > 0) {
      _currentRouteIndex--;
    } else {
      _currentRouteIndex = _allRoutes.length - 1;
    }
    currentRoute = _allRoutes[_currentRouteIndex];
    _displayRoute(currentRoute);
  }

  void _routeSwipeLeft() {
    if (_currentRouteIndex < _allRoutes.length - 1) {
      _currentRouteIndex++;
    } else {
      _currentRouteIndex = 0;
    }
    currentRoute = _allRoutes[_currentRouteIndex];
    _displayRoute(currentRoute);
  }

  Future<void> _startJourney() async {
    var startMarker = markers
        .where((marker) => marker.markerId.value == 'startMarker')
        .firstOrNull;
    mapController
        .animateCamera(CameraUpdate.newLatLngZoom(startMarker!.position, 15.0));

    // Switch to detailed view in the Positioned widget
    isJourneyStarted = true;

    // Extract and populate finalStopsList with LatLng coordinates
    finalStopsList.clear(); // Clear the list to start fresh
    finalBusStopsNotified = 0;

    if (currentRoute != null && currentRoute['legs'] != null) {
      for (var leg in currentRoute['legs']) {
        int count = 0;
        for (var step in leg['steps']) {
          if (step['travel_mode'] == 'TRANSIT') {
            final transitDetails = step['transit_details'];
            if (transitDetails != null) {
              final arrivalStop = transitDetails['arrival_stop'];
              if (arrivalStop != null) {
                final stopLocation = LatLng(
                  double.parse(
                      roundCoordinates(arrivalStop['location']['lat'])),
                  double.parse(
                      roundCoordinates(arrivalStop['location']['lng'])),
                );
                final stepLine = transitDetails['line'];
                final match = codeMapping.entries.firstWhere((entry) {
                  final newKey = entry.key.toLowerCase();
                  final mappingAlias =
                      entry.value['alias'].toString().toLowerCase();
                  return newKey ==
                          stepLine['short_name']
                              .toString()
                              .replaceAll('-', '')
                              .toLowerCase() ||
                      mappingAlias ==
                          stepLine['name'].toString().toLowerCase() ||
                      mappingAlias ==
                          stepLine['alias'].toString().toLowerCase();
                });
                var tempFinalStop =
                    FinalBusStop(count, stopLocation, match.value['newCode']);
                finalStopsList.add(tempFinalStop);
                count += 1;
              }
            }
          }
        }
      }
    }

    int userId = (await UserService.getUserId())!;
    String token = (await UserService.getToken())!;
    Trip tempTrip = Trip(
        startDate: DateTime.now(),
        endDate: DateTime.fromMicrosecondsSinceEpoch(0),
        userId: userId,
        totalPrice: -1);
    currentTrip = await TripService.postTrip(tempTrip, token);
    while (busStopsList.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300));
    }
    // Create a Map using the coordinates as keys for quick access
    Map<String, BusStop> busStopCoordinatesMap = {};
    // Populate the Map
    for (var busStop in busStopsList) {
      busStopCoordinatesMap['${busStop.latitude},${busStop.longitude}'] =
          busStop;
    }
    // Update currentRouteBusDetails
    for (var currentBus in currentRouteBusDetails) {
      List<String> startCoordinates = currentBus.startCoordinates.split(',');
      List<String> finishCoordinates = currentBus.finalCoordinates.split(',');

      // Get BusStop objects directly from the Map using coordinates as keys
      BusStop? originBusStop = busStopCoordinatesMap[
          '${startCoordinates[0]},${startCoordinates[1]}'];
      BusStop? destinationBusStop = busStopCoordinatesMap[
          '${finishCoordinates[0]},${finishCoordinates[1]}'];
      currentBus.tripId = currentTrip.tripId!;

      // Check if BusStop objects exist for the coordinates
      if (originBusStop != null) {
        currentBus.originStopId = originBusStop.busStopId;
      }

      if (destinationBusStop != null) {
        currentBus.destinationStopId = destinationBusStop.busStopId;
      }
      var postedTripDetail =
          await TripService.postTripDetail(currentBus, token);
      currentBus.tripDetailId = postedTripDetail.tripDetailId;
    }

    setState(() {});
  }

  void _payForJourney() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScannerPage(
          allowedBusesList: currentRouteBusNames,
          callback: (dynamic data) {
            // Handle the received data from the second screen here
            debugPrint(
                'Data received in MapScreen from TicketInfoScreen: $data');
            paidBusFinalStop =
                finalStopsList.firstWhere((e) => e.busLineName == data.busName);
            setState(() {
              isPaidTrip = true;
              enableFinishJourneyBtn = false;
            });
          },
        ),
      ),
    );
  }

  void _finishJourney() async {
    isJourneyStarted = false;
    var tripToUpdate = currentTrip;
    tripToUpdate.totalPrice =
        tripToUpdate.totalPrice == -1 ? 0 : tripToUpdate.totalPrice;
    tripToUpdate.endDate = DateTime.now();
    String token = (await UserService.getToken())!;
    currentTrip = await TripService.updateTrip(tripToUpdate, token);
    var userId = await UserService.getUserId();
    var currentRating = 0;
    var commentController = TextEditingController();
    var pageViewController = PageController(viewportFraction: 1);
    setState(
      () {
        // show bottom sheet to rate each bus line
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          isDismissible: false,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: PageView.builder(
                  itemCount: currentRouteBusNames.length,
                  controller: pageViewController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Califica tu viaje',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          Text(
                            'Línea: ${currentRouteBusNames[index]}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 40,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              currentRating = rating.toInt();
                            },
                          ),
                          const SizedBox(height: 8.0),
                          TextField(
                            maxLines: 2,
                            controller: commentController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintMaxLines: 2,
                              hintText: 'Deja un comentario',
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.grey.shade100),
                                  foregroundColor:
                                      MaterialStateProperty.all<Color>(
                                          Colors.black),
                                ),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  //if currentRating = 0, show error
                                  if (currentRating == 0) {
                                    //show dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Calificación no válida'),
                                          content: const Text(
                                              'Por favor, califica tu viaje.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('Cerrar'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    return;
                                  }

                                  var rating = Rating(
                                    value: currentRating,
                                    comment: commentController.text,
                                    passengerId: userId!,
                                    tripDetailId: currentRouteBusDetails[index]
                                        .tripDetailId,
                                  );
                                  RatingService.postRating(rating);
                                  if (pageViewController.page!.toInt() ==
                                      currentRouteBusNames.length - 1) {
                                    Navigator.pop(context);
                                  } else {
                                    commentController.clear();
                                    pageViewController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                child: const Text('Enviar'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _finishPaidJourney() async {
    isPaidTrip = false;
    //keep trip going but pay ticket/ add cost to trip
    var tripToUpdate = currentTrip;
    tripToUpdate.totalPrice = tripToUpdate.totalPrice + 1.5;
    String token = (await UserService.getToken())!;
    currentPassenger = await loadPassengerData();
    double newPassengerBalance =
        double.parse(currentPassenger!.wallet!.balance) - 1.5;
    currentPassenger!.wallet!.balance = newPassengerBalance.toString();
    currentTrip = await TripService.updateTrip(tripToUpdate, token);
    await WalletService.putWallet(currentPassenger!.wallet!, token);
    setState(() {});
  }

  int getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return int.parse(hexColor, radix: 16);
  }

  Future<void> fetchAndDisplayDirections(
      LatLng origin, LatLng destination) async {
    try {
      final directions = await directionsService.getDirections(
        origin: origin,
        destination: destination,
      );
      allPolylines = [];
      setState(() {
        polylines.clear();
      });
      if (directions != null && directions['routes'] != null) {
        List<dynamic> routes = directions['routes'];

        routes.removeWhere((route) {
          final steps = route['legs'][0]['steps'];
          final polylines = steps
              .map((step) => step['polyline']['points'])
              .toList(); // Extract polylines
          bool validPolylines = true;
          bool similarPolylines = arePolylinesSimilar(polylines);

          if (allPolylines.isEmpty || !similarPolylines) {
            allPolylines.add(polylines);
            validPolylines = true;
          } else if (similarPolylines) {
            validPolylines = false;
          }

          final hasInvalidStep = steps.any((step) {
            if (step['travel_mode'] == 'TRANSIT' &&
                step.containsKey('transit_details') &&
                step['transit_details'].containsKey('line')) {
              final line = step['transit_details']['line'];
              final shortName =
                  (line.containsKey('short_name') ? line['short_name'] : '')
                      .replaceAll('-', '')
                      .toLowerCase();
              final alias = line.containsKey('alias')
                  ? line['alias'].toLowerCase()
                  : line.containsKey('name')
                      ? line['name'].toLowerCase()
                      : '';

              // Check if the short_name and alias match the oldCode and alias in codeMapping
              return !codeMapping.keys.any((key) {
                final newKey = key.toLowerCase();
                final mappingAlias = codeMapping[key]!['alias'].toLowerCase();
                return newKey == shortName ||
                    (mappingAlias != "" &&
                        alias != "" &&
                        mappingAlias == alias);
              });
            }
            return false;
          });

          return hasInvalidStep || !validPolylines;
        });

        // Sort routes based on travel time
        routes.sort((a, b) {
          int timeA = a['legs'][0]['duration']['value'];
          int timeB = b['legs'][0]['duration']['value'];
          return timeA.compareTo(timeB);
        });

        // Store all routes for swipe navigation
        _allRoutes = routes;
        _currentRouteIndex = 0; // Start with the quickest route
        currentRoute = _allRoutes[_currentRouteIndex];

        // Initially, display the quickest route
        _displayRoute(routes[0]);
      }
    } catch (e) {
      // Handle errors
      debugPrint(e.toString());
    }
  }

  bool arePolylinesSimilar(List<dynamic> polyline1) {
    for (var polyline2 in allPolylines) {
      bool similar = true;
      for (int i = 0; i < polyline1.length; i++) {
        if (polyline1[i] != polyline2[i]) {
          similar = false;
          break;
        }
      }
      if (similar) {
        return true;
      }
    }
    return false;
  }

  String roundCoordinates(dynamic value) {
    double fixedValue =
        double.parse(double.parse(value.toString()).toStringAsFixed(7));
    String stringValue = fixedValue.toString();
    return stringValue;
  }

  void _displayRoute(dynamic route) {
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
              PatternItem.dash(5),
              PatternItem.gap(5)
            ], // Dotted pattern
          );
        } else if (step['travel_mode'] == 'TRANSIT') {
          String busLineColor = "#0000FF";
          var stepLine = step['transit_details']['line'];
          final match = codeMapping.entries.firstWhere((entry) {
            final newKey = entry.key.toLowerCase();
            final mappingAlias = entry.value['alias'].toString().toLowerCase();
            return newKey ==
                    stepLine['short_name']
                        .toString()
                        .replaceAll('-', '')
                        .toLowerCase() ||
                mappingAlias == stepLine['name'].toString().toLowerCase() ||
                mappingAlias == stepLine['alias'].toString().toLowerCase();
          });

          busLineColor = match.value['color'];

          Color lineColor =
              Color(int.parse("0xFF${busLineColor.replaceFirst('#', '')}"));

          polyline = Polyline(
            polylineId: PolylineId('step${step['start_location']}'),
            color: lineColor,
            width: 5,
            points: stepPolylinePoints,
          );
        }

        if (polyline != null) {
          // Associate polyline with its step data
          polylines[polyline] = step;
        }
      }
    }

    routePreviewInfo.clear();

    for (var leg in route['legs']) {
      for (var step in leg['steps']) {
        if (step['travel_mode'] == 'WALKING') {
          routePreviewInfo.add({
            'type': 'walking',
            'duration': step['duration']['text'],
          });
        } else if (step['travel_mode'] == 'TRANSIT') {
          String busName = step['transit_details']['line']['short_name'] ??
              step['transit_details']['line']['alias'] ??
              step['transit_details']['line']['name'] ??
              '0000';

          // Extracting and rounding coordinates
          String startCoordinates =
              '${roundCoordinates(step['start_location']["lat"])},${roundCoordinates(step['start_location']["lng"])}';
          String endCoordinates =
              '${roundCoordinates(step['end_location']["lat"])},${roundCoordinates(step['end_location']["lng"])}';

          routePreviewInfo.add({
            'type': 'transit',
            'duration': step['duration']['text'],
            'start_coordinates': startCoordinates,
            'end_coordinates': endCoordinates,
            'short_name': busName.replaceAll('-', ''),
            'color': step['transit_details']['line']['color'],
          });
        }
      }
    }

    currentRouteBusDetails = [];
    int orderCount = 0;
    currentRouteBusNames = [];

    for (var info in routePreviewInfo) {
      if (info['type'] != 'walking') {
        final match = codeMapping.entries.firstWhere((entry) {
          final newKey = entry.key.toLowerCase();
          final mappingAlias = entry.value['alias'].toString().toLowerCase();
          return newKey == info['short_name'].toString().toLowerCase() ||
              mappingAlias == info['short_name'].toString().toLowerCase();
        });

        TripDetail tempTripDetail = TripDetail(
          tripId: 0,
          tripDetailId: 0,
          startCoordinates: info['start_coordinates'],
          finalCoordinates: info['end_coordinates'],
          vehicleTypeId: 1,
          lineId: match.value['lineId'],
          originStopId: 0,
          destinationStopId: 0,
          order: orderCount,
          price: 0,
        );
        // Update the short_name and color properties
        info['short_name'] = match.value['newCode'].length > 1
            ? match.value['newCode']
            : match.value['alias'];
        info['color'] = match.value['color'];
        orderCount++;
        currentRouteBusNames.add(info['short_name'].toString());
        currentRouteBusDetails.add(tempTripDetail);
      }
    }

// Initialize routeInfo
    List<String> routeInfo = [];

// Iterate through the steps in the route
    for (var leg in route['legs']) {
      for (var step in leg['steps']) {
        String instruction = step['html_instructions'];

        // Remove HTML tags
        instruction = instruction.replaceAll(RegExp('<[^>]+>'), '');

        if (step['travel_mode'] == 'TRANSIT' &&
            step.containsKey('transit_details')) {
          final transitDetails = step['transit_details']['line'];
          final match = codeMapping.entries.firstWhere((entry) {
            final newKey = entry.key.toLowerCase();
            final mappingAlias = entry.value['alias'].toString().toLowerCase();
            return newKey ==
                    transitDetails['short_name'].toString().toLowerCase() ||
                mappingAlias ==
                    transitDetails['short_name'].toString().toLowerCase();
          });

          final newCode = match.value['newCode'];
          final alias = match.value['alias'];
          final lineInfo =
              (alias != "") ? ' (vía $newCode - $alias)' : ' (vía $newCode)';
          instruction += lineInfo;
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
    final places = GoogleMapsPlaces(
      apiKey: kGoogleApiKey,
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    final detail = await places.getDetailsByPlaceId(p.placeId!);
    final geometry = detail.result.geometry!;
    final lat = geometry.location.lat;
    final lng = geometry.location.lng;

    // Create a LatLng object from the coordinates
    final targetLocation = LatLng(lat, lng);

    // Create a Marker object
    final MarkerId markerId = type == 'start'
        ? const MarkerId('startMarker')
        : const MarkerId('finishMarker');
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
        for (var marker in markers) {
          if (marker.markerId.value == 'startMarker') {
            originCoords = marker.position;
          } else if (marker.markerId.value == 'finishMarker') {
            destinationCoords = marker.position;
          }
        }

        // Check if both origin and destination coordinates are available
        if (originCoords != null && destinationCoords != null) {
          // Call the fetchAndDisplayDirections function with the coordinates
          fetchAndDisplayDirections(originCoords, destinationCoords);
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
      int? headway, String? arrivalTime, String busName, String busShortName) {
    // Calculate future departure times
    DateTime now = DateTime.now();
    DateTime departureTime = now.add(Duration(minutes: timeToBusStop));

    List<DateTime> departureTimes = [];

    if (headway != null) {
      // Use the headway for 5 times
      for (int i = 0; i < 5; i++) {
        departureTime = departureTime.add(Duration(seconds: headway));
        departureTimes.add(departureTime);
      }
    } else if (arrivalTime != null) {
      DateTime now = DateTime.now();
      List<String> parts = arrivalTime.split(":");
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      DateTime tempArrivalTime =
          DateTime(now.year, now.month, now.day, hour, minute);

      departureTimes.add(tempArrivalTime);
    }

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
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text("${time.hour}:${time.minute}"),
                );
              }).toList(),
              const SizedBox(height: 10),
              TextButton(
                child: (!isJourneyStarted)
                    ? ElevatedButton(
                        onPressed: _startJourney,
                        child: const Text("Iniciar Viaje"))
                    : ElevatedButton(
                        onPressed: _payForJourney,
                        child: const Column(
                          children: [
                            Text("Pagar Pasaje"),
                            Text("Escanear QR"),
                          ],
                        )),
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

  Future<Passenger?> loadPassengerData() async {
    final int? userId = await UserService.getUserId();
    final String? token = await UserService.getToken();

    if (userId != null && token != null) {
      return PassengerService.getPassengerByUserId(userId, token);
    }
    return null;
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
