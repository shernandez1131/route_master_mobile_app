class User {
  final int userId;
  final String email;
  final String password;
  final String? token;
  final String? username;
  final bool? isActive;

  User(
      {required this.userId,
      required this.email,
      required this.password,
      this.token,
      this.username,
      this.isActive});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
      username: json['username'],
      isActive: json['isActive'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'password': password,
        'token': token,
        'username': username,
        'isActive': isActive,
      };
}
