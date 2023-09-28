class User {
  final int userId;
  final String email;
  final String password;
  final String? token;
  final String? username;

  User(
      {required this.userId,
      required this.email,
      required this.password,
      this.token,
      this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'password': password,
        'token': token,
        'username': username,
      };
}
