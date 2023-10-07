import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(isReadOnly ? Icons.edit : Icons.save),
            onPressed: () async {
              if (!isReadOnly) {
                setState(() {
                  isReadOnly = true;
                  isUpdating = true;
                });
                await updatePassengerData().then((value) => setState(() {
                      isUpdating = false;
                    }));
              } else {
                setState(() {
                  isReadOnly = false;
                });
              }
            },
          ),
        ],
      ),
      body: FutureBuilder<Passenger?>(
        future: passengerFuture,
        builder: (BuildContext context, AsyncSnapshot<Passenger?> snapshot) {
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
              phoneNumberController =
                  TextEditingController(text: passenger.phoneNumber);
              paymentMethodController = TextEditingController(
                  text: passenger.paymentMethodId.toString());
              firstLoad = false;
            }

            return Stack(
              children: [
                ListView(
                  children: [
                    CircleAvatar(
                      radius: 50, // Adjust the size as needed
                      child: ClipOval(
                        child: Image.asset('images/profile_icon.png'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.history),
                                onPressed: () {
                                  // Navigate to the TransactionHistoryScreen when the history icon is pressed
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const TransactionHistoryScreen(),
                                    ),
                                  );
                                },
                              ),
                              Text(
                                'Saldo: S/${passenger.wallet!.balance.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
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
                            selectedPaymentMethodId: passenger.paymentMethodId,
                            isReadOnly: isReadOnly,
                          ),
                          ProfileField(
                            label: 'Celular',
                            initialValue: "${passenger.phoneNumber}",
                            isReadOnly: isReadOnly,
                            controller: phoneNumberController,
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (GoogleSignIn().currentUser != null) {
                                await GoogleSignIn().disconnect();
                              }
                              if (context.mounted) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) => const SignInScreen(),
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
                        color: Colors.black
                            .withOpacity(0.5), // Semi-transparent background
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
    );
  }
}
