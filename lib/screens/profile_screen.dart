import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:route_master_mobile_app/screens/tickets_history_screen.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/services.dart';
import 'screens.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late Future<Passenger?> passengerFuture;
  bool isReadOnly = true;
  bool firstLoad = true;
  bool isUpdating = false;

  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController lastName2Controller;
  late TextEditingController phoneNumberController;
  late TextEditingController paymentMethodController;

  @override
  void initState() {
    super.initState();
    passengerFuture = loadPassengerData();
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
      body: Row(
        children: <Widget>[
          Expanded(
            child: Stack(
              children: [
                Scaffold(
                  body: FutureBuilder<Passenger?>(
                    future: passengerFuture,
                    builder: (BuildContext context,
                        AsyncSnapshot<Passenger?> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child:
                                CircularProgressIndicator()); // Show a loading indicator while fetching data
                      } else if (snapshot.hasError || snapshot.data == null) {
                        return const Text('Error loading data'); // Handle error
                      } else {
                        final passenger = snapshot.data!;

                        if (firstLoad) {
                          firstNameController =
                              TextEditingController(text: passenger.firstName);
                          lastNameController =
                              TextEditingController(text: passenger.lastName);
                          lastName2Controller =
                              TextEditingController(text: passenger.lastName2);
                          phoneNumberController = TextEditingController(
                              text: passenger.phoneNumber);
                          paymentMethodController = TextEditingController(
                              text: passenger.paymentMethodId.toString());
                          firstLoad = false;
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
                                              Text(
                                                'Saldo:',
                                                style: const TextStyle(
                                                    fontSize: 20),
                                              ),
                                              Text(
                                                'S/${passenger.wallet!.balance.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            ],
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              // Navigate to the AddFundsScreen when the add icon is pressed
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const AddFundsScreen(),
                                                ),
                                              );
                                            },
                                          ),
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
                    icon: Icon(Icons.menu),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white, // Set your desired color
              ),
              child: Image.asset(
                'images/route_master_logo.png',
                width: 100, // Set your desired width
                height: 100, // Set your desired height
              ),
            ),
            ListTile(
              leading: Icon(Icons.directions_bus), // Icon for Trip History
              title: Text('Historial de Viajes'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TripHistoryScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.receipt), // Icon for Ticket History
              title: Text('Historial de Boletos'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TicketsHistoryScreen(),
                ));
              },
            ),
            ListTile(
              leading: Icon(Icons.history), // Icon for Transaction History
              title: Text('Historial de Transacciones'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => TransactionHistoryScreen(),
                ));
              },
            ),
          ],
        ),
      ),
    );
  }
}
