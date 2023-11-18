import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:route_master_mobile_app/extensions.dart';
import 'package:route_master_mobile_app/screens/bus_route_screen.dart';
import '../models/models.dart';
import '../services/services.dart';

class FavoriteLinesScreen extends StatefulWidget {
  const FavoriteLinesScreen({super.key});

  @override
  State<FavoriteLinesScreen> createState() => _FavoriteLinesScreenState();
}

class _FavoriteLinesScreenState extends State<FavoriteLinesScreen> {
  late TextEditingController _controller;

  List<BusLine> displayedBusLines = [];
  late Future<List<BusLine>> passengerFavoriteBusLines;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  Future<List<BusLine>> getFavoriteBusLines() async {
    final userId = await UserService.getUserId();
    if (userId != null) {
      passengerFavoriteBusLines =
          BusLineService.getFavoriteBusLinesByUserId(userId);
    }
    return passengerFavoriteBusLines;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> refreshBusLines() async {
    displayedBusLines = await BusLineService.getBusLines();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Líneas Favoritas'),
      ),
      body: FutureBuilder(
        future: getFavoriteBusLines(),
        builder: (context, snapshot) {
          void filterBusLines(String query) {
            setState(() {
              query = removeDiacritics(query).toLowerCase();
              if (query.length < 3) {
                displayedBusLines = snapshot.data!
                    .where((line) =>
                        removeDiacritics(line.code)
                            .toLowerCase()
                            .contains(query) ||
                        removeDiacritics(line.firstStop)
                            .toLowerCase()
                            .contains(query) ||
                        removeDiacritics(line.lastStop)
                            .toLowerCase()
                            .contains(query) ||
                        removeDiacritics(line.company!.name)
                            .toLowerCase()
                            .contains(query) ||
                        removeDiacritics(line.alias ?? '')
                            .toLowerCase()
                            .contains(query))
                    .toList();
              } else {
                displayedBusLines = snapshot.data!
                    .where((line) =>
                        removeDiacritics(line.code)
                            .toLowerCase()
                            .startsWith(query) ||
                        removeDiacritics(line.firstStop)
                            .toLowerCase()
                            .split(' ')
                            .any((element) => element.startsWith(query)) ||
                        removeDiacritics(line.lastStop)
                            .toLowerCase()
                            .split(' ')
                            .any((element) => element.startsWith(query)) ||
                        removeDiacritics(line.company!.name)
                            .toLowerCase()
                            .contains(query) ||
                        removeDiacritics(line.alias ?? '')
                            .toLowerCase()
                            .contains(query))
                    .toList();
              }
            });
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('An error has occurred!'),
            );
          } else if (snapshot.hasData) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Material(
                    elevation: 4.0,
                    borderRadius: BorderRadius.circular(30.0),
                    child: TextField(
                      controller: _controller,
                      onChanged: (value) {
                        filterBusLines(value);
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'Busca una línea de bus',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14.0, horizontal: 0.0),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _controller.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  setState(() {
                                    _controller.clear();
                                    filterBusLines('');
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                  });
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: refreshBusLines,
                    child: GroupedListView(
                      elements: [
                        for (var busLine in snapshot.data!)
                          {
                            'lineId': busLine.lineId,
                            'color': busLine.color.toColor(),
                            'code': busLine.code,
                            'firstStop': busLine.firstStop,
                            'lastStop': busLine.lastStop,
                            'alias': busLine.alias,
                            'companyId': busLine.companyId,
                            'companyName': busLine.company!.name,
                            'busLineTypeName': busLine.vehicleType!.name,
                            'oldCode': busLine.oldCode,
                            'logo': busLine.logo,
                          }
                      ],
                      groupBy: (Map<String, dynamic> element) =>
                          element['companyId'],
                      //groupComparator: (value1, value2) => value2.compareTo(value1),
                      itemComparator: (item1, item2) =>
                          item1['lineId'].compareTo(item2['lineId']),
                      order: GroupedListOrder.ASC,
                      useStickyGroupSeparators: true,
                      separator: const Divider(
                        indent: 16,
                        endIndent: 16,
                      ),
                      groupHeaderBuilder: (Map<String, dynamic> element) =>
                          Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.grey.withOpacity(0.2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              right: 16.0, left: 16.0, top: 8.0, bottom: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  element['companyName'],
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal),
                                ),
                              ),
                              Text(
                                element['busLineTypeName'],
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                        ),
                      ),
                      itemBuilder: (context, Map<String, dynamic> element) {
                        return GestureDetector(
                          onTap: () {
                            _openBusStopsMap(element['lineId']);
                          },
                          child: ListTile(
                            title: Row(
                              children: [
                                element['logo'] == ""
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
                                                color: element['color'],
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
                                                element['code'],
                                                style: const TextStyle(
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Image.memory(
                                        base64Decode(element['logo']),
                                        width: 36,
                                        height: 36,
                                        scale: 1.5,
                                      ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(element['alias'] == null
                                      ? element['firstStop'] +
                                          ' - ' +
                                          element['lastStop']
                                      : element['firstStop'] +
                                          ' - ' +
                                          element['lastStop'] +
                                          ' [' +
                                          element['alias']! +
                                          ']'),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  void _openBusStopsMap(id) async {
    fetchBusStopsByBusLineId(id).then((value) => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BusRouteScreen(busStops: value),
          ),
        ));
  }

  Future<List<BusStop>> fetchBusStopsByBusLineId(id) async {
    return await BusStopService.getBusStopsByUserId(id);
  }
}
