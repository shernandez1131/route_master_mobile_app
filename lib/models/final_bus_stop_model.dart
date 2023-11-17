import 'package:google_maps_flutter/google_maps_flutter.dart';

class FinalBusStop {
  final int order;
  final LatLng coordinates;
  final String busLineName;

  FinalBusStop(
    this.order,
    this.coordinates,
    this.busLineName,
  );
}
