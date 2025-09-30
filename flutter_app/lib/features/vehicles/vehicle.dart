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
    this.pricePerDay,
    this.rating,
  });

  String get title => '$make $model $year';
  String get transmissionLabel => transmission == 'AT' ? 'Automatic' : 'Manual';

  factory Vehicle.fromJson(Map<String, dynamic> j) => Vehicle(
    vehicle_id: j['vehicle_id'] as String,
    make: j['make'] as String,
    model: j['model'] as String,
    year: (j['year'] as num).toInt(),
    plate: j['plate'] as String,
    seats: (j['seats'] as num).toInt(),
    transmission: j['transmission'] as String,
    fuelType: j['fuel_type'] as String,
    mileage: (j['mileage'] as num).toInt(),
    status: j['status'] as String,
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    // si tu backend empieza a mandar estos campos, se leen; si no, quedan null
    pricePerDay: (j['price_per_day'] as num?)?.toDouble(),
    rating: (j['rating'] as num?)?.toDouble(),
  );

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
    if (pricePerDay != null) 'price_per_day': pricePerDay,
    if (rating != null) 'rating': rating,
  };
}
