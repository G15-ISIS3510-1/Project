// lib/features/vehicles/vehicle.dart
class Vehicle {
  final String vehicle_id;
  final String make;
  final String model;
  final int year;
  final String plate;
  final int seats;
  final String transmission; // "AT" | "MT"
  final String fuelType; // "gas" | "diesel" | ...
  final int mileage;
  final String status; // "active" | ...
  final double lat;
  final double lng;
  final String photo_url;

  // NUEVO: dueño y fecha de creación (que vienen en tu payload)
  final String ownerId;
  final DateTime? createdAt;

  // Opcional: si tu API luego envía precio/rating
  final double? pricePerDay;
  final double? rating;

  Vehicle({
    required this.vehicle_id,
    required this.make,
    required this.model,
    required this.year,
    required this.plate,
    required this.seats,
    required this.transmission,
    required this.fuelType,
    required this.mileage,
    required this.status,
    required this.lat,
    required this.lng,
    required this.ownerId,
    this.createdAt,
    this.pricePerDay,
    this.rating,
    this.photo_url = '',
  });

  String get title => '$make $model $year';
  String get transmissionLabel => transmission == 'AT' ? 'Automatic' : 'Manual';

  factory Vehicle.fromJson(Map<String, dynamic> j) {
    DateTime? _parseDate(dynamic v) {
      if (v == null) return null;
      if (v is DateTime) return v;
      if (v is String && v.isNotEmpty) {
        try {
          return DateTime.parse(v);
        } catch (_) {}
      }
      return null;
    }

    double _toDouble(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.parse(v.toString()));
    int _toInt(dynamic v) =>
        v == null ? 0 : (v is num ? v.toInt() : int.parse(v.toString()));

    return Vehicle(
      vehicle_id: j['vehicle_id'] as String,
      make: j['make'] as String,
      model: j['model'] as String,
      year: _toInt(j['year']),
      plate: j['plate'] as String,
      seats: _toInt(j['seats']),
      transmission: j['transmission'] as String,
      fuelType: (j['fuel_type'] ?? j['fuelType']) as String,
      mileage: _toInt(j['mileage']),
      status: j['status'] as String,
      lat: _toDouble(j['lat']),
      lng: _toDouble(j['lng']),

      // nuevos
      ownerId: (j['owner_id'] ?? j['ownerId']) as String,
      createdAt: _parseDate(j['created_at'] ?? j['createdAt']),

      // opcionales si llegan
      pricePerDay:
          (j['price_per_day'] as num?)?.toDouble() ??
          (j['pricePerDay'] as num?)?.toDouble(),
      rating: (j['rating'] as num?)?.toDouble(),

      photo_url: (j['photo_url'] ?? j['photoUrl'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'vehicle_id': vehicle_id,
    'make': make,
    'model': model,
    'year': year,
    'plate': plate,
    'seats': seats,
    'transmission': transmission,
    'fuel_type': fuelType,
    'mileage': mileage,
    'status': status,
    'lat': lat,
    'lng': lng,
    'owner_id': ownerId,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (pricePerDay != null) 'price_per_day': pricePerDay,
    if (rating != null) 'rating': rating,
    'photo_url': photo_url,
  };
}
