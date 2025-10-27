// lib/presentation/features/booking/viewmodel/booking_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/app/utils/date_format.dart';
import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

class BookingViewModel extends ChangeNotifier {
  final BookingsRepository bookingsRepo;
  final ChatRepository chatRepo;

  bool isLoading = false;
  String? errorMessage;

  BookingViewModel({required this.bookingsRepo, required this.chatRepo});

  Future<bool> createBooking(BookingCreateModel data) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final res = await bookingsRepo.createBooking(data);

    return res.when(
      ok: (Booking booking) async {
        isLoading = false;
        notifyListeners();

        // ---- Crear/Asegurar thread sin bloquear el éxito del booking ----
        try {
          final startLocal = booking.startTs.toLocal();
          final endLocal = booking.endTs.toLocal();
          final initialMessage =
              '✅ Reserva creada para el vehículo ${booking.vehicleId}\n'
              'Del ${formatDateTime(startLocal)} al ${formatDateTime(endLocal)}\n'
              'Total: ${booking.total.toStringAsFixed(2)} ${booking.currency}';

          // intenta crear un thread con metadata de booking/vehicle
          await chatRepo.createThread(
            renterId: booking.renterId,
            hostId: booking.hostId,
            vehicleId: booking.vehicleId,
            bookingId: booking.bookingId,
            initialMessage: initialMessage,
          );
        } catch (e) {
          // Si ya existe o falló (409/400/etc.), asegúralo directo entre usuarios
          try {
            // Elegimos "otro usuario" en función de quién es el renter
            final otherUserId = data.renterId == booking.renterId
                ? booking.hostId
                : booking.renterId;
            await chatRepo.ensureDirectConversation(otherUserId);
          } catch (_) {
            // No interrumpimos la UX; solo podrías loguearlo si quieres
          }
        }

        return true;
      },
      err: (msg) async {
        isLoading = false;
        errorMessage = msg;
        notifyListeners();
        return false;
      },
    );
  }
}
