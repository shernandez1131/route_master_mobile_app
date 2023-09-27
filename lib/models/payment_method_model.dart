class PaymentMethod {
  final int paymentMethodId;
  final String name;

  PaymentMethod({required this.paymentMethodId, required this.name});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      paymentMethodId: json['paymentMethodId'],
      name: json['name'],
    );
  }
}
