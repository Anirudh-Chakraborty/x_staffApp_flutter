import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import '../models/product.dart';
import '../models/order.dart';

class ApiService {
  // Change this to your backend URL - use 10.0.2.2 for Android emulator, or your computer's IP for physical device
  static const String baseUrl = 'http://10.0.2.2:3003';

  // For Android emulator use: 'http://10.0.2.2:3000'
  // For physical device use your computer's IP: 'http://192.168.x.x:3000'

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Login failed');
    }
  }

  Future<User> signup(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': 'Staff'
      }),
    );

    if (response.statusCode == 201) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Signup failed');
    }
  }

  Future<List<Product>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/products/search?q=$query'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Search failed');
    }
  }

  Future<Order> createOrder(
      String userId, String productId, int quantity) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {'Content-Type': 'application/json', 'x-user-id': userId},
      body: jsonEncode({'productId': productId, 'quantity': quantity}),
    );

    if (response.statusCode == 201) {
      return Order.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Order failed');
    }
  }

  Future<List<Order>> getOrders(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/orders'),
      headers: {'x-user-id': userId},
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Order.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }
}
