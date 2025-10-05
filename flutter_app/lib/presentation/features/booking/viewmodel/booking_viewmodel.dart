import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_app/data/models/booking_create_model.dart';

class BookingViewModel extends ChangeNotifier {
  final String baseUrl = const String.fromEnvironment(
    'API_BASE',
    defaultValue: 'http://10.0.2.2:8000',
  );

  bool _loading = false;
  bool get isLoading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> createBooking(BookingCreateModel bookingData) async {
    _setLoading(true);
    _setErrorMessage(null);

    try {
      final url = Uri.parse('$baseUrl/api/bookings'); 

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(bookingData.toJson()),
      );

      _setLoading(false);

      if (res.statusCode == 201) {
        return true;
      } else {
        String detail = 'Error desconocido';
        try {
          final Map<String, dynamic> errorBody = jsonDecode(res.body);
          detail = errorBody['detail'] ?? 'Error desconocido';
        } catch (_) {
          detail = res.body.isEmpty ? 'Respuesta vacía o inválida del servidor.' : res.body;
        }
        
        _setErrorMessage('Error ${res.statusCode}: $detail');
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setErrorMessage('⚠️ Error de red/conexión: $e');
      return false;
    }
  }
}