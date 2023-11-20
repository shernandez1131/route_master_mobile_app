import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:route_master_mobile_app/models/models.dart';
import 'package:route_master_mobile_app/screens/favorite_lines_screen.dart';
import 'package:route_master_mobile_app/screens/tickets_history_screen.dart';
import 'package:route_master_mobile_app/services/services.dart';
import 'package:route_master_mobile_app/services/transaction_service.dart';
import 'package:route_master_mobile_app/widgets/widgets.dart';
import 'screens.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart' as st;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<Passenger?> passengerFuture;
  late Passenger _passenger;
  bool isReadOnly = true;
  bool firstLoad = true;
  bool isUpdating = false;
  bool isPaymentPanelVisible = false;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController lastName2Controller;
  late TextEditingController phoneNumberController;
  late TextEditingController paymentMethodController;
  late TextEditingController _amountController;
  late double rechargeAmount;
  double transferAmount = 0.0;
  late String passengerBalance;
  Map<String, dynamic>? paymentIntent;

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  Future<void> refreshData() async {
    setState(() {
      passengerFuture = loadPassengerData();
      print("Test");
    });
  }

  Future<Passenger?> loadPassengerData() async {
    final int? userId = await UserService.getUserId();
    final String? token = await UserService.getToken();

    if (userId != null && token != null) {
      return PassengerService.getPassengerByUserId(userId, token);
    }
    return null;
  }

  Future<Passenger?> updatePassengerData() async {
    final int? userId = await UserService.getUserId();
    final String? token = await UserService.getToken();
    if (userId != null && token != null) {
      final Passenger passenger = Passenger(
          userId: userId,
          firstName: firstNameController.text,
          lastName: lastNameController.text,
          phoneNumber: phoneNumberController.text,
          isActive: true,
          paymentMethodId: int.parse(paymentMethodController.text));

      return PassengerService.updatePassenger(userId, passenger, token);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: RefreshIndicator(
        onRefresh: refreshData,
        child: Row(
          children: <Widget>[
            Expanded(
              child: Stack(
                children: [
                  Scaffold(
                    body: FutureBuilder<Passenger?>(
                      future: passengerFuture,
                      builder: (BuildContext context,
                          AsyncSnapshot<Passenger?> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child:
                                  CircularProgressIndicator()); // Show a loading indicator while fetching data
                        } else if (snapshot.hasError || snapshot.data == null) {
                          return const Text(
                              'Error loading data'); // Handle error
                        } else {
                          final passenger = snapshot.data!;
                          _passenger = snapshot.data!;
                          passengerBalance = _passenger.wallet!.balance;

                          if (firstLoad) {
                            firstNameController = TextEditingController(
                                text: passenger.firstName);
                            lastNameController =
                                TextEditingController(text: passenger.lastName);
                            lastName2Controller = TextEditingController(
                                text: passenger.lastName2);
                            phoneNumberController = TextEditingController(
                                text: passenger.phoneNumber);
                            paymentMethodController = TextEditingController(
                                text: passenger.paymentMethodId.toString());
                            firstLoad = false;
                            UserService.saveWalletId(
                                _passenger.wallet!.walletId);
                          }

                          return Stack(
                            children: [
                              ListView(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: CircleAvatar(
                                      radius: 50, // Adjust the size as needed
                                      child: ClipOval(
                                        child: Image.asset(
                                            'images/profile_icon.png'),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: <Widget>[
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Column(
                                              children: [
                                                const Text(
                                                  'Saldo:',
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                Text(
                                                  'S/${double.parse(passengerBalance).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                )
                                              ],
                                            )
                                          ],
                                        ),
                                        ProfileField(
                                          label: 'Nombre(s)',
                                          initialValue: passenger.firstName,
                                          isReadOnly: isReadOnly,
                                          controller: firstNameController,
                                        ),
                                        ProfileField(
                                          label: 'Apellido(s)',
                                          initialValue: passenger.lastName,
                                          isReadOnly: isReadOnly,
                                          controller: lastNameController,
                                        ),
                                        PaymentMethodDropdownField(
                                          selectedPaymentMethodId:
                                              passenger.paymentMethodId,
                                          isReadOnly: isReadOnly,
                                        ),
                                        ProfileField(
                                          label: 'Celular',
                                          initialValue:
                                              "${passenger.phoneNumber}",
                                          isReadOnly: isReadOnly,
                                          controller: phoneNumberController,
                                        ),
                                        ElevatedButton(
                                          onPressed: () async {
                                            bool? isGoogleSignIn =
                                                await UserService
                                                    .getGoogleSignIn();
                                            if (isGoogleSignIn != null &&
                                                isGoogleSignIn) {
                                              await GoogleSignIn().disconnect();
                                            }
                                            await UserService.removeAll();
                                            if (context.mounted) {
                                              Navigator.of(context)
                                                  .pushAndRemoveUntil(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const SignInScreen(),
                                                ),
                                                (route) =>
                                                    false, // This effectively removes all routes from the stack
                                              );
                                            }
                                          },
                                          child: const Text('Cerrar Sesión'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              isUpdating
                                  ? Container(
                                      color: Colors.black.withOpacity(
                                          0.5), // Semi-transparent background
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : const SizedBox.shrink(), // An
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 30,
                    left: 5,
                    child: IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () {
                        _scaffoldKey.currentState?.openDrawer();
                      },
                    ),
                  ),
                  Positioned(
                    top: 30,
                    right: 5,
                    child: IconButton(
                      icon: Icon(isReadOnly ? Icons.edit : Icons.save),
                      onPressed: () async {
                        if (!isReadOnly) {
                          setState(() {
                            isReadOnly = true;
                            isUpdating = true;
                          });
                          await updatePassengerData()
                              .then((value) => setState(() {
                                    isUpdating = false;
                                  }));
                        } else {
                          setState(() {
                            isReadOnly = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.white, // Set your desired color
              ),
              child: Image.asset(
                'images/route_master_logo.png',
                width: 100, // Set your desired width
                height: 100, // Set your desired height
              ),
            ),
            ListTile(
              leading: const Icon(Icons.star), // Icon for Favorite Lines
              title: const Text('Líneas favoritas'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const FavoriteLinesScreen(),
                ));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.directions_bus), // Icon for Trip History
              title: const Text('Historial de Viajes'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TripHistoryScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt), // Icon for Ticket History
              title: const Text('Historial de Boletos'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TicketsHistoryScreen(),
                ));
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.history), // Icon for Transaction History
              title: const Text('Historial de Transacciones'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ));
              },
            ),
            ListTile(
              leading: const Icon(Icons.add), // Icon for Transaction History
              title: const Text('Recargar Monedero'),
              onTap: () {
                _scaffoldKey.currentState?.closeDrawer();
                _showRecargarDialog();
              },
            ),
            ListTile(
              leading: const Icon(
                  Icons.mobile_screen_share), // Icon for Transaction History
              title: const Text('Compartir Saldo'),
              onTap: () {
                _scaffoldKey.currentState?.closeDrawer();
                _showTransferDialog();
              },
            ),
            ListTile(
              leading: const Icon(
                  Icons.monetization_on), // Icon for Transaction History
              title: const Text('Recibir Saldo'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .push(MaterialPageRoute(
                      builder: (context) =>
                          const TransferBalanceWaitingScreen(),
                    ))
                    .then((value) => refreshData());
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRecargarDialog() {
    _amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recargar Monedero'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('¿Cuál monto desea recargar en su monedero?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('S/. ', style: TextStyle(fontSize: 20)),
                  SizedBox(
                    width: 150,
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}$'),
                        ),
                      ],
                      decoration: const InputDecoration(
                        hintText: 'Monto',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                // Add logic to handle the recharge action
                String amountText = _amountController.text.trim();
                if (amountText.isNotEmpty) {
                  rechargeAmount = double.parse(amountText);
                  // Validate and use the 'amount' value
                  debugPrint('Recargar $rechargeAmount PEN');
                }
                setState(() {
                  isPaymentPanelVisible = true;
                });
                Navigator.of(context).pop(); // Close the dialog
                makePayment();
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.green),
                foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
              ),
              child: const Text('Recargar'),
            ),
          ],
        );
      },
    );
  }

  void _showTransferDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TransferDialog(
          passengerBalance: passengerBalance,
          onTransferComplete: () {
            refreshData();
          },
        );
      },
    );
  }

  void makePayment() async {
    try {
      paymentIntent = await createPaymentIntent();
      var gpay = const st.PaymentSheetGooglePay(
          merchantCountryCode: "ES", currencyCode: "ES", testEnv: true);
      await st.Stripe.instance
          .initPaymentSheet(
            paymentSheetParameters: st.SetupPaymentSheetParameters(
                customFlow: true,
                paymentIntentClientSecret: paymentIntent!["client_secret"],
                style: ThemeMode.light,
                merchantDisplayName: "RouteMaster",
                googlePay: gpay,
                primaryButtonLabel: "Pagar S/. ${(rechargeAmount).toString()}"),
          )
          .then((value) => displayPaymentSheet());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void displayPaymentSheet() async {
    try {
      await st.Stripe.instance.presentPaymentSheet();
      await st.Stripe.instance.confirmPaymentSheetPayment();
      double existingBalance = double.parse(passengerBalance);
      double newBalance = existingBalance + rechargeAmount;
      Wallet wallet = Wallet(
          walletId: _passenger.wallet!.walletId,
          userId: _passenger.wallet!.userId,
          balance: newBalance.toString(),
          lastUpdate: DateTime.now());
      var token = await UserService.getToken();
      await WalletService.putWallet(wallet, token!)
          .then((value) => setState(() {
                passengerBalance = value.balance;
                _showRechargeConfirmation();
              }));
      TransactionService.createRechargeTransaction(Transaction(
          walletId: _passenger.wallet!.walletId,
          amount: rechargeAmount,
          date: DateTime.now(),
          status: "Success",
          description: "Recarga de monedero"));
      debugPrint("Payment sheet displayed successfully");
    } catch (e) {
      throw Exception("Error displaying payment sheet: $e");
    }
  }

  createPaymentIntent() async {
    try {
      Map<String, dynamic> body = {
        "amount": (rechargeAmount * 100).round().toString(),
        "currency": "usd",
      };
      http.Response response = await http.post(
          Uri.parse("https://api.stripe.com/v1/payment_intents"),
          body: body,
          headers: {
            "Authorization":
                "Bearer sk_test_51OBC14Ew7UVJPn6si1ymYg76Pnin479ybVJaLCbzJ0qOT1zte6zTXXTWxlPXGx3DFbyH8G45za6PJhHVkOHbVMXi00umsm9NJP",
            "Content-Type": "application/x-www-form-urlencoded",
          });
      return json.decode(response.body);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  void _showRechargeConfirmation() async {
    // Display the notification
    NotificationService.showNotification(
      'Recarga confirmada',
      'Su recarga de S/. ${rechargeAmount.toStringAsFixed(2)} ha sido confirmada',
    );
  }
}
