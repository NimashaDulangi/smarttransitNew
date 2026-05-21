import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<Map<String, String>> getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ==================== AUTH ====================
  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // ==================== BUSES ====================
  static Future<List<dynamic>> getBuses() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/buses'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> createBus(
      String busNumber, int capacity) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/buses'),
      headers: headers,
      body: jsonEncode({'bus_number': busNumber, 'capacity': capacity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateBus(
      String id, String busNumber, int capacity) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/buses/$id'),
      headers: headers,
      body: jsonEncode({'bus_number': busNumber, 'capacity': capacity}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteBus(String id) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/buses/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // ==================== ROUTES ====================
  static Future<List<dynamic>> getRoutes() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/routes'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> createRoute(String routeName,
      String startLocation, String endLocation, double distanceKm) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/routes'),
      headers: headers,
      body: jsonEncode({
        'route_name': routeName,
        'start_location': startLocation,
        'end_location': endLocation,
        'distance_km': distanceKm,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateRoute(String id, String routeName,
      String startLocation, String endLocation, double distanceKm) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/routes/$id'),
      headers: headers,
      body: jsonEncode({
        'route_name': routeName,
        'start_location': startLocation,
        'end_location': endLocation,
        'distance_km': distanceKm,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteRoute(String id) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/routes/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  // ==================== BOOKINGS ====================
  static Future<List<dynamic>> getBookings() async {
    final headers = await getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/api/bookings'),
      headers: headers,
    );
    final data = jsonDecode(response.body);
    return data['data'] ?? [];
  }

  static Future<Map<String, dynamic>> createBooking(
      String busId,
      String routeId,
      String passengerName,
      String passengerPhone,
      int seatNumber) async {
    final headers = await getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/api/bookings'),
      headers: headers,
      body: jsonEncode({
        'bus_id': busId,
        'route_id': routeId,
        'passenger_name': passengerName,
        'passenger_phone': passengerPhone,
        'seat_number': seatNumber,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> updateBooking(
      String id,
      String busId,
      String routeId,
      String passengerName,
      String passengerPhone,
      int seatNumber) async {
    final headers = await getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/api/bookings/$id'),
      headers: headers,
      body: jsonEncode({
        'bus_id': busId,
        'route_id': routeId,
        'passenger_name': passengerName,
        'passenger_phone': passengerPhone,
        'seat_number': seatNumber,
      }),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> deleteBooking(String id) async {
    final headers = await getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/api/bookings/$id'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }
}