import 'dart:ffi';

class Passenger {
  final int userId;
  final String firstName;
  final String lastName;
  final String? lastName2;
  final String? phoneNumber;
  final bool isActive;
  final int paymentMethodId;
  Passenger(
      {required this.userId,
      required this.firstName,
      required this.lastName,
      this.lastName2,
      this.phoneNumber,
      required this.isActive,
      required this.paymentMethodId});
}
