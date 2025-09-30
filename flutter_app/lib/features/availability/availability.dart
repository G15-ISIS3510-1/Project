// lib/features/availability/availability.dart
class AvailabilityWindow {
  final String availability_id;
  final String vehicle_id;
  final DateTime start;
  final DateTime end;
  final String type; // "available" | "blocked" (según tu backend)
  final String? notes;

  AvailabilityWindow({
    required this.availability_id,
    required this.vehicle_id,
    required this.start,
    required this.end,
    required this.type,
    this.notes,
  });

  factory AvailabilityWindow.fromJson(Map<String, dynamic> j) =>
      AvailabilityWindow(
        availability_id: j['availability_id'].toString(),
        vehicle_id: j['vehicle_id'].toString(),
        start: DateTime.parse(j['start_ts']), // ISO-8601 "Z" ok
        end: DateTime.parse(j['end_ts']),
        type: j['type'] as String,
        notes: j['notes'] as String?,
      );
}
