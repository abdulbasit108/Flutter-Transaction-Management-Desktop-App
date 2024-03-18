import 'dart:convert';

class User {
  final int id; // Change the type to int
  final String token;
  final String username;
  final String email;
  final bool isAdmin;

  User({
    required this.id,
    required this.token,
    required this.username,
    required this.email,
    required this.isAdmin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'token': token,
      'username': username,
      'email': email,
      'is_admin': isAdmin,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    final userData = map['data']['user'];
    return User(
      id: userData['id'] ?? -1, // Provide a default value if id is null
      token: map['data']['token'] ?? '',
      username: userData['username'] ?? '',
      email: userData['email'] ?? '',
      isAdmin: userData['is_admin'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  User copyWith({
    int? id,
    String? token,
    String? username,
    String? email,
    bool? isAdmin,
  }) {
    return User(
      id: id ?? this.id,
      token: token ?? this.token,
      username: username ?? this.username,
      email: email ?? this.email,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
