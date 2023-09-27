import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';
import '../services/services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
    final int? userId = await LoginService.getUserId();
    final String? token = await LoginService.getToken();

    if (userId != null && token != null) {
      return PassengerService.getPassengerByUserId(userId, token);
    }
    return null;
  }

  Future<Passenger?> updatePassengerData() async {
    final int? userId = await LoginService.getUserId();
    final String? token = await LoginService.getToken();
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
      ),
      body: FutureBuilder<Passenger?>(
        future: passengerFuture,
        builder: (BuildContext context, AsyncSnapshot<Passenger?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator()); // Show a loading indicator while fetching data
          } else if (snapshot.hasError || snapshot.data == null) {
            return Text('Error loading data'); // Handle error
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
                      radius: 70, // Adjust the size as needed
                      child: ClipOval(
                        child: Image.asset('images/profile_icon.png'),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
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
                              if (!isReadOnly) {
                                setState(() {
                                  isReadOnly = true;
                                  isUpdating = true;
                                });
                                await updatePassengerData()
                                    .then((value) => setState(() {
                                          isUpdating = false;
                                        }));
                                return;
                              }
                              setState(() {
                                isReadOnly = false;
                              });
                            },
                            child:
                                isReadOnly ? Text('Editar') : Text('Guardar'),
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
