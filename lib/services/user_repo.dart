import 'dart:convert';
import 'package:http/http.dart' as http;

/// A simple user model
class User {
  final int id;
  final String name;
  final String email;

  User({required this.id, required this.name, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
    );
  }
}

/// A repository that fetches user data from an API
/// This demonstrates dependency injection of http.Client
class UserRepository {
  final http.Client client;
  final String baseUrl;

  // Dependency Injection: Pass the client in the constructor
  UserRepository(
      {required this.client,
      this.baseUrl = 'https://jsonplaceholder.typicode.com'});

  Future<User?> fetchUser(int id) async {
    final response = await client.get(Uri.parse('$baseUrl/users/$id'));

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }
}
