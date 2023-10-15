import 'package:diacritic/diacritic.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:route_master_mobile_app/extensions.dart';
import '../models/models.dart';

class LinesScreen extends StatefulWidget {
  const LinesScreen({super.key});

  @override
  State<LinesScreen> createState() => _LinesScreenState();
}

class _LinesScreenState extends State<LinesScreen> {
  final List<BusLine> allBusLines = [
    BusLine(
      busLineId: 1,
      code: '201',
      firstStop: 'Ate',
      lastStop: 'Callao',
      color: "#ff0201",
      company: Company(
        companyId: 1,
        name: 'Corredor Rojo',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 2,
      code: '204',
      firstStop: 'La Molina',
      lastStop: 'San Miguel',
      color: "#ff0201",
      company: Company(
        companyId: 1,
        name: 'Corredor Rojo',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 3,
      code: '206',
      firstStop: 'La Molina',
      lastStop: 'San Miguel',
      color: "#ff0201",
      company: Company(
        companyId: 1,
        name: 'Corredor Rojo',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 4,
      code: '209',
      firstStop: 'Ate',
      lastStop: 'San Miguel',
      color: "#ff0201",
      company: Company(
        companyId: 1,
        name: 'Corredor Rojo',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 5,
      code: '301',
      firstStop: 'Rímac',
      lastStop: 'Barranco',
      color: "#2211e3",
      company: Company(
        companyId: 1,
        name: 'Corredor Azul',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 6,
      code: '303',
      firstStop: 'San Juan de Lurigancho',
      lastStop: 'Miraflores',
      color: "#2211e3",
      company: Company(
        companyId: 1,
        name: 'Corredor Azul',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 7,
      code: '305',
      firstStop: 'Rímac',
      lastStop: 'Miraflores',
      color: "#2211e3",
      company: Company(
        companyId: 1,
        name: 'Corredor Azul',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 5,
      code: '336',
      firstStop: 'Rímac',
      lastStop: 'Miraflores',
      color: "#2211e3",
      company: Company(
        companyId: 1,
        name: 'Corredor Azul',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
    BusLine(
      busLineId: 5,
      code: '370',
      firstStop: 'Rímac',
      lastStop: 'Rímac',
      color: "#2211e3",
      company: Company(
        companyId: 1,
        name: 'Corredor Azul',
        ruc: '12345678901',
      ),
      companyId: 1,
      lineType: LineType(
        lineTypeId: 1,
        name: 'Autobús',
      ),
      lineTypeId: 1,
    ),
  ];

  List<BusLine> displayedBusLines = [];

  @override
  void initState() {
    displayedBusLines = allBusLines;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Líneas de Bus'),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(right: 16.0, left: 16.0, bottom: 16.0),
            child: TextField(
              onChanged: (value) {
                filterBusLines(value);
              },
              decoration: const InputDecoration(
                labelText: 'Busca una línea de bus',
              ),
            ),
          ),
          Expanded(
            child: GroupedListView(
              elements: [
                for (var busLine in displayedBusLines)
                  {
                    'color': busLine.color.toColor(),
                    'code': busLine.code,
                    'firstStop': busLine.firstStop,
                    'lastStop': busLine.lastStop,
                    'companyName': busLine.company!.name,
                    'busLineTypeName': busLine.lineType!.name,
                  }
              ],
              groupBy: (Map<String, dynamic> element) => element['companyName'],
              //groupComparator: (value1, value2) => value2.compareTo(value1),
              //itemComparator: (item1, item2) =>
              //    item1['topicName'].compareTo(item2['topicName']),
              //order: GroupedListOrder.DESC,
              // useStickyGroupSeparators: true,
              separator: const Divider(
                indent: 16,
                endIndent: 16,
              ),
              groupHeaderBuilder: (Map<String, dynamic> element) => Container(
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
                      Text(
                        element['companyName'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      ),
                      Text(
                        element['busLineTypeName'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                ),
              ),
              itemBuilder: (context, Map<String, dynamic> element) {
                return ListTile(
                  leading: Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.grey.withOpacity(0.5),
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
                    width: element['code'].length == 3
                        ? 57
                        : element['code'].length == 4
                            ? 67
                            : 77,
                    child: Row(
                      children: [
                        const Icon(Icons.directions_bus),
                        Text(element['code'],
                            style: const TextStyle(fontSize: 15)),
                      ],
                    ),
                  ),
                  title:
                      Text(element['firstStop'] + ' - ' + element['lastStop']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void filterBusLines(String query) {
    setState(() {
      query = removeDiacritics(query).toLowerCase();
      displayedBusLines = allBusLines
          .where((line) =>
              removeDiacritics(line.code).toLowerCase().contains(query) ||
              removeDiacritics(line.firstStop).toLowerCase().contains(query) ||
              removeDiacritics(line.lastStop).toLowerCase().contains(query) ||
              removeDiacritics(line.company!.name)
                  .toLowerCase()
                  .contains(query))
          .toList();
    });
  }
}
