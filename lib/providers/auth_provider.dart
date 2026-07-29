import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  User? _user;
  bool _isLoading = false;
  
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  Future<(bool, String?, String?)> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final response = await _apiClient.dio.post('login', data: {
        'email': email,
        'password': password,
      });
      
      final token = response.data['access_token'];
      if (token != null) {
        await _storage.write(key: 'auth_token', value: token);
        _user = User.fromJson(response.data['user']);
        _isLoading = false;
        notifyListeners();
        return (true, null, null);
      }
    } on DioException catch (e) {
      debugPrint('Login error: ${e.response?.data}');
      debugPrint('DioException details: ${e.message} | type: ${e.type}');
      
      String endpoint = e.requestOptions.path;
      String message = 'Error de conexión o servidor inalcanzable';
      
      if (e.response?.data is Map && e.response?.data['message'] != null) {
        message = e.response!.data['message'].toString();
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
      
      debugPrint('Returning error to UI: $message for endpoint $endpoint');
      
      _isLoading = false;
      notifyListeners();
      return (false, message, endpoint);
    }
    
    _isLoading = false;
    notifyListeners();
    return (false, 'Invalid response format', 'login');
  }

  Future<void> logout() async {
    try {
      await _apiClient.dio.post('logout');
    } catch (e) {
      debugPrint('Logout error: $e');
    }
    
    await _storage.delete(key: 'auth_token');
    _user = null;
    notifyListeners();
  }

  Future<void> checkAuth() async {
    final token = await _storage.read(key: 'auth_token');
    if (token != null) {
      try {
        final response = await _apiClient.dio.get('me');
        _user = User.fromJson(response.data['user'] ?? response.data);
      } catch (e) {
        await _storage.delete(key: 'auth_token');
        _user = null;
      }
    }
    notifyListeners();
  }
}
