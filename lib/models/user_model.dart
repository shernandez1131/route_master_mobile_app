class User {
  final String email;
  final String password;
  final String? username;

  User({required this.email, required this.password, this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      password: json['password'],
      username: json['username'],
    );
  }
}
