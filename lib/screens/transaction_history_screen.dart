import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = ['Todos', 'Recargas', 'Pagos', 'Transferencias'];

  // Dummy data for each tab
  final List<List<String>> tabData = [
    ['Transaction 1', 'Transaction 2', 'Transaction 3'],
    ['Recarga 1', 'Recarga 2'],
    ['Pago 1', 'Pago 2', 'Pago 3'],
    ['Transferencia 1', 'Transferencia 2'],
  ];

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Transacciones'),
        bottom: TabBar(
          controller: _tabController,
          tabs: tabs.map((String tab) {
            return Tab(
              text: tab,
            );
          }).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: tabs.map((String tab) {
          final tabIndex = tabs.indexOf(tab);
          return ListView.builder(
            itemCount: tabData[tabIndex].length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ListTile(
                      leading: const Icon(Icons.receipt),
                      title: Text(tabData[tabIndex][index]),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(
                      height: 1.0,
                      color: Colors.grey.withOpacity(
                          0.5), // Adjust opacity for a fainter appearance
                      indent: 16, // Adjust the left indent
                      endIndent: 16, // Adjust the right indent
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
