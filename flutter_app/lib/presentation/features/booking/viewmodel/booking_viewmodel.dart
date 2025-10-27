import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart';

class BookingViewModel extends ChangeNotifier {
  BookingViewModel({required this.bookingsRepo, required this.chatRepo});

  final BookingsRepository bookingsRepo; // si lo usas para otras cosas
  final ChatRepository chatRepo;

  bool _loading = false;
  String? _error;
  bool get isLoading => _loading;
  String? get errorMessage => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? m) {
    _error = m;
    notifyListeners();
  }

  Future<bool> createBooking(BookingCreateModel data) async {
    _setLoading(true);
    _setError(null);
    try {
      final resp = await BookingService().create(data.toJson());
      _setLoading(false);

      if (resp.statusCode == 201) {
        // parsea el booking_id para crear thread
        final j = jsonDecode(resp.body) as Map<String, dynamic>;
        final bookingId = j['booking_id']?.toString() ?? '';
        final renterId = j['renter_id']?.toString() ?? data.renterId;
        final hostId = j['host_id']?.toString() ?? data.hostId;
        final vehicleId = j['vehicle_id']?.toString() ?? data.vehicleId;

        // crea conversación renter-host vinculada al booking
        try {
          await chatRepo.createThread(
            renterId: renterId,
            hostId: hostId,
            vehicleId: vehicleId,
            bookingId: bookingId,
            initialMessage:
                '¡Hola! Tengo una reserva del ${data.startTs} al ${data.endTs}.',
          );
        } catch (_) {
          // si falla chat, no rompas la reserva
        }

        return true;
      } else {
        String detail = 'Error ${resp.statusCode}';
        try {
          final j = jsonDecode(resp.body);
          detail = j['detail']?.toString() ?? detail;
        } catch (_) {}
        _setError(detail);
        return false;
      }
    } catch (e) {
      _setLoading(false);
      _setError(e.toString());
      return false;
    }
  }
}
