import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/models/models.dart';
import 'package:route_master_mobile_app/screens/ticket_info_screen.dart';
import 'package:route_master_mobile_app/services/services.dart'; // Import your TicketInfoScreen

class TicketsHistoryScreen extends StatefulWidget {
  const TicketsHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TicketsHistoryScreen> createState() => _TicketsHistoryScreenState();
}

class _TicketsHistoryScreenState extends State<TicketsHistoryScreen>
    with SingleTickerProviderStateMixin {
  late List<Ticket> tabData = [];
  late Function(dynamic) emptyCallback;

  @override
  void initState() {
    super.initState();
    fetchTickets().then((data) {
      data.sort((a, b) => b.createdOn.compareTo(a.createdOn));
      setState(() {
        tabData = data;
      });
    });
  }

  Future<List<Ticket>> fetchTickets() async {
    var userId = await UserService.getUserId();
    return await TicketService.getTicketsByUser(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Boletos'),
      ),
      body: ListView.builder(
        itemCount: tabData.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TicketInfoScreen(
                    ticket: tabData[index],
                    isFromQrScan: false,
                    callback: emptyCallback,
                  ),
                ),
              );
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListTile(
                    leading: const Icon(Icons.receipt),
                    title: Text(
                      '${tabData[index].busName} (#${tabData[index].number.toString().padLeft(7, '0')})',
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tabData[index].companyName),
                        Text(
                          '${tabData[index].createdOn.day}/${tabData[index].createdOn.month}/${tabData[index].createdOn.year} ${tabData[index].createdOn.hour}:${tabData[index].createdOn.minute}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: Text(
                      tabData[index].amount.toString() == ""
                          ? 'S/. ${tabData[index].amount}'
                          : "No Pagado",
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
          );
        },
      ),
    );
  }
}
