import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../database/tables/pricing_table.dart';
import '../models/pricing_model.dart'; // ajusta ruta si difiere

// DB row -> Modelo
extension PricingRowToModel on PricingData {
  Pricing toModel() => Pricing(
    pricing_id: pricingId,
    vehicleId: vehicleId,
    dailyPrice: dailyPrice,
    minDays: minDays,
    maxDays: maxDays ?? 0,
    currency: currency,
  );
}

// Modelo -> DB
PricingsCompanion pricingModelToDb(Pricing p) {
  DateTime _asDt(Object? v) {
    if (v is DateTime) return v.toUtc();
    return DateTime.parse(v as String).toUtc();
  }

  return PricingsCompanion(
    pricingId: Value(p.pricing_id),
    vehicleId: Value(p.vehicleId),
    dailyPrice: Value(p.dailyPrice),
    minDays: Value(p.minDays),
    maxDays: Value(p.maxDays),
    currency: Value(p.currency),
    isDeleted: const Value(false),
  );
}
