import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:route_master_mobile_app/extensions.dart';
import 'package:route_master_mobile_app/models/models.dart';
import 'package:route_master_mobile_app/services/services.dart';
import 'package:route_master_mobile_app/services/trip_service.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen>
    with SingleTickerProviderStateMixin {
  late List<Trip> tabData = [];

  @override
  void initState() {
    super.initState();
    fetchTrips().then((data) {
      data.sort((a, b) => b.startDate.compareTo(a.startDate));
      setState(() {
        tabData = data;
      });
    });
  }

  Future<List<Trip>> fetchTrips() async {
    var userId = await UserService.getUserId();
    return await TripService.getTripsByUser(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Viajes'),
      ),
      body: ListView.builder(
        itemCount: tabData.length,
        itemBuilder: (BuildContext context, int index) {
          return ExpansionTile(
            title: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    title: Wrap(
                      spacing: 7.0,
                      runSpacing: 4.0,
                      children: tabData[index].tripDetails!.map((tripDetail) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey.withOpacity(0.5),
                              width: 1,
                            ),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: tripDetail.busLine!.color.toColor(),
                                spreadRadius: 0,
                                blurRadius: 0,
                                offset: const Offset(5, 0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4.0,
                              vertical: 2.0,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.directions_bus),
                                Text(
                                  tripDetail.busLine!.code.length > 1
                                      ? tripDetail.busLine!.code
                                      : tripDetail.busLine!.alias!,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            'Inicio: ${DateFormat('dd/MM/yyyy HH:mm').format(tabData[index].startDate)}'),
                        (tabData[index].endDate !=
                                DateTime.fromMicrosecondsSinceEpoch(0))
                            ? Text(
                                'Final: ${DateFormat('dd/MM/yyyy HH:mm').format(tabData[index].endDate)}')
                            : const SizedBox.shrink(),
                      ],
                    ),
                    trailing: Text(
                      tabData[index].totalPrice < 0
                          ? 'En curso'
                          : 'S/. ${tabData[index].totalPrice}',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Divider(
                    height: 1.0,
                    color: Colors.grey.withOpacity(0.5),
                    indent: 16,
                    endIndent: 16,
                  ),
                ),
              ],
            ),
            children: [
              //for each trip detail in trip show the trip details rating
              for (var tripDetail in tabData[index].tripDetails!)
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1,
                          ),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: tripDetail.busLine!.color.toColor(),
                              spreadRadius: 0,
                              blurRadius: 0,
                              offset: const Offset(5, 0),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.0,
                            vertical: 2.0,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.directions_bus),
                              Text(
                                tripDetail.busLine!.code.length > 1
                                    ? tripDetail.busLine!.code
                                    : tripDetail.busLine!.alias!,
                                style: const TextStyle(fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ),
                      tripDetail.rating != null
                          ? RatingBarIndicator(
                              rating: tripDetail.rating!.value.toDouble(),
                              itemBuilder: (context, index) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            )
                          : Text(
                              'Sin calificar',
                            ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
