import 'package:flutter/foundation.dart';
import '../../../../data/models/booking_reminder_model.dart';
import '../../../../data/repositories/analytics_repository.dart';

class BookingReminderViewModel extends ChangeNotifier {
  final AnalyticsRepository _repository;

  BookingReminderViewModel(this._repository);

  BookingReminderListModel? _bookingReminders;
  UpcomingBookingsListModel? _upcomingBookings;
  bool _isLoading = false;
  String? _errorMessage;

  BookingReminderListModel? get bookingReminders => _bookingReminders;
  UpcomingBookingsListModel? get upcomingBookings => _upcomingBookings;

  // Método para inyectar datos de prueba (Mocking)
  void setMockUpcomingBookings(UpcomingBookingsListModel bookings) {
    _upcomingBookings = bookings;
    notifyListeners();
  }

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBookingReminders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _bookingReminders = await _repository.getBookingsNeedingReminder();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUpcomingBookings(String userId, {int hoursAhead = 24}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _upcomingBookings = await _repository.getUserUpcomingBookings(
        userId,
        hoursAhead: hoursAhead,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}