import 'dart:convert';

import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:route_master_mobile_app/extensions.dart';
import 'package:route_master_mobile_app/services/bus_line_service.dart';
import '../models/models.dart';

class LinesScreen extends StatefulWidget {
  const LinesScreen({super.key});

  @override
  State<LinesScreen> createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  late TextEditingController _controller;
  late Future<List<BusLine>> busLines;

  List<BusLine> displayedBusLines = [];

  @override
  void initState() {
    super.initState();
    //displayedBusLines = allBusLines;
    busLines =
        BusLineService.getBusLines().then((value) => displayedBusLines = value);
    _controller = TextEditingController();
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
        title: const Text('Líneas de Bus'),
      ),
      body: FutureBuilder<List<BusLine>>(
          future: busLines,
          builder: (context, snapshot) {
            void filterBusLines(String query) {
              setState(() {
                query = removeDiacritics(query).toLowerCase();
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
                      padding: const EdgeInsets.only(
                          right: 16.0, left: 16.0, bottom: 8),
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          filterBusLines(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Busca una línea de bus',
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _controller.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _controller.clear();
                                    filterBusLines('');
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    setState(() {});
                                  },
                                )
                              : null,
                        ),
                      )),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: refreshBusLines,
                      child: GroupedListView(
                        elements: [
                          for (var busLine in displayedBusLines)
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
                          return ListTile(
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
          }),
    );
  }
}
