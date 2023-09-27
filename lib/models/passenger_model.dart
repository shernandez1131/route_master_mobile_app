import 'models.dart';

class Passenger {
  final int userId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? lastName2;
  final String? phoneNumber;
  final bool isActive;
  final int paymentMethodId;
  final User? user;
  final PaymentMethod? paymentMethod;

  Passenger(
      {required this.userId,
      required this.firstName,
      this.middleName,
      required this.lastName,
      this.lastName2,
      this.phoneNumber,
      required this.isActive,
      required this.paymentMethodId,
      this.user,
      this.paymentMethod});

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      userId: json['userId'],
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      lastName2: json['lastName2'],
      phoneNumber: json['phoneNumber'],
      isActive: json['isActive'],
      paymentMethodId: json['paymentMethodId'],
      user: User.fromJson(json['user']),
      paymentMethod: PaymentMethod.fromJson(json['paymentMethod']),
    );
  }
}
