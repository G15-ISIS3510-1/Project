class BookingReminderModel {
  final String bookingId;
  final String renterId;
  final String vehicleId;
  final DateTime startTs;
  final int minutesUntilStart;
  final bool shouldNotify;
  final String timeRemainingFormatted;

  BookingReminderModel({
    required this.bookingId,
    required this.renterId,
    required this.vehicleId,
    required this.startTs,
    required this.minutesUntilStart,
    required this.shouldNotify,
    required this.timeRemainingFormatted,
  });

  factory BookingReminderModel.fromJson(Map<String, dynamic> json) {
    return BookingReminderModel(
      bookingId: json['booking_id'],
      renterId: json['renter_id'],
      vehicleId: json['vehicle_id'],
      startTs: DateTime.parse(json['start_ts']),
      minutesUntilStart: json['minutes_until_start'],
      shouldNotify: json['should_notify'],
      timeRemainingFormatted: json['time_remaining_formatted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'renter_id': renterId,
      'vehicle_id': vehicleId,
      'start_ts': startTs.toIso8601String(),
      'minutes_until_start': minutesUntilStart,
      'should_notify': shouldNotify,
      'time_remaining_formatted': timeRemainingFormatted,
    };
  }
}

class BookingReminderListModel {
  final List<BookingReminderModel> bookings;
  final int thresholdHours;
  final int totalCount;

  BookingReminderListModel({
    required this.bookings,
    required this.thresholdHours,
    required this.totalCount,
  });

  factory BookingReminderListModel.fromJson(Map<String, dynamic> json) {
    return BookingReminderListModel(
      bookings: (json['bookings'] as List)
          .map((item) => BookingReminderModel.fromJson(item))
          .toList(),
      thresholdHours: json['threshold_hours'],
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookings': bookings.map((b) => b.toJson()).toList(),
      'threshold_hours': thresholdHours,
      'total_count': totalCount,
    };
  }
}

class UpcomingBookingModel {
  final String bookingId;
  final String vehicleId;
  final DateTime startTs;
  final DateTime endTs;
  final double hoursUntilStart;
  final bool reachedThreshold;
  final String timeRemainingFormatted;

  UpcomingBookingModel({
    required this.bookingId,
    required this.vehicleId,
    required this.startTs,
    required this.endTs,
    required this.hoursUntilStart,
    required this.reachedThreshold,
    required this.timeRemainingFormatted,
  });

  factory UpcomingBookingModel.fromJson(Map<String, dynamic> json) {
    return UpcomingBookingModel(
      bookingId: json['booking_id'],
      vehicleId: json['vehicle_id'],
      startTs: DateTime.parse(json['start_ts']),
      endTs: DateTime.parse(json['end_ts']),
      hoursUntilStart: json['hours_until_start'].toDouble(),
      reachedThreshold: json['reached_threshold'],
      timeRemainingFormatted: json['time_remaining_formatted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'booking_id': bookingId,
      'vehicle_id': vehicleId,
      'start_ts': startTs.toIso8601String(),
      'end_ts': endTs.toIso8601String(),
      'hours_until_start': hoursUntilStart,
      'reached_threshold': reachedThreshold,
      'time_remaining_formatted': timeRemainingFormatted,
    };
  }
}

class UpcomingBookingsListModel {
  final String userId;
  final List<UpcomingBookingModel> bookings;
  final int hoursAhead;
  final int totalCount;

  UpcomingBookingsListModel({
    required this.userId,
    required this.bookings,
    required this.hoursAhead,
    required this.totalCount,
  });

  factory UpcomingBookingsListModel.fromJson(Map<String, dynamic> json) {
    return UpcomingBookingsListModel(
      userId: json['user_id'],
      bookings: (json['bookings'] as List)
          .map((item) => UpcomingBookingModel.fromJson(item))
          .toList(),
      hoursAhead: json['hours_ahead'],
      totalCount: json['total_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'bookings': bookings.map((b) => b.toJson()).toList(),
      'hours_ahead': hoursAhead,
      'total_count': totalCount,
    };
  }
}