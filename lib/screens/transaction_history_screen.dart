import 'package:flutter/material.dart';
import 'package:route_master_mobile_app/models/transaction_model.dart';
import 'package:route_master_mobile_app/services/transaction_service.dart';
import 'package:route_master_mobile_app/services/user_service.dart';
import 'package:intl/intl.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen>
    with SingleTickerProviderStateMixin {
  final List<String> tabs = ['Todos', 'Pagos', 'Recargas', 'Transferencias'];

  late TabController _tabController;

  Future<List<Transaction>> _getTransactions() async {
    // Get the transactions from the service
    final walletId = await UserService.getWalletId();
    if (walletId == null) {
      throw Exception('WalletId is null');
    }
    return TransactionService.getTransactionsByWalletId(walletId);
  }

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
      body: FutureBuilder<List<Transaction>>(
          future: _getTransactions(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text('Error al obtener las transacciones'),
              );
            }
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final transactions = snapshot.data!;
            transactions.sort((a, b) => b.date.compareTo(a.date));
            final tabData = [
              transactions,
              transactions
                  .where((transaction) => transaction.transactionTypeId == 1)
                  .toList(),
              transactions
                  .where((transaction) => transaction.transactionTypeId == 2)
                  .toList(),
              transactions
                  .where((transaction) => transaction.transactionTypeId == 3)
                  .toList(),
            ];

            return TabBarView(
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
                            title: Text(tabData[tabIndex][index].description),
                            subtitle: Text(DateFormat('dd/MM/yyyy HH:mm')
                                .format(tabData[tabIndex][index].date)),
                            trailing: Text(
                                '${tabData[tabIndex][index].transactionTypeId == 2 ? "+" : "-"}S/${tabData[tabIndex][index].amount.toStringAsFixed(2)}',
                                style: TextStyle(
                                    fontSize: 14.0,
                                    fontWeight: FontWeight.bold,
                                    color: tabData[tabIndex][index]
                                                .transactionTypeId ==
                                            2
                                        ? Colors.green
                                        : Colors.red)),
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
            );
          }),
    );
  }
}
