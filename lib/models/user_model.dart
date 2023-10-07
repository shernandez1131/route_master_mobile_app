class User {
  final int? userId;
  final String email;
  final String? password;
  final String? token;
  final String? username;
  final bool? isActive;
  final String? googleId;

  User(
      {this.userId,
      required this.email,
      this.password,
      this.token,
      this.username,
      this.isActive,
      this.googleId});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
      username: json['username'],
      isActive: json['isActive'],
      googleId: json['googleId'],
    );
  }

  factory User.fromJsonLogin(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      token: json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'token': token,
        'username': username,
        'isActive': isActive,
        'googleId': googleId,
      };

  Map<String, dynamic> toJsonLogin() => {
        'email': email,
        'password': password,
      };
}
