import 'package:flutter_app/data/models/booking_model.dart';
import 'package:flutter_app/presentation/common_widgets/trip_card.dart';
import 'package:intl/intl.dart';

typedef VehicleNameResolver = String Function(String vehicleId);

class BookingMappers {
  static TripItem toItem(Booking b, {VehicleNameResolver? resolveVehicleName}) {
    final fmt = DateFormat('dd MMM yyyy', 'es');
    final range = '${fmt.format(b.startTs)} - ${fmt.format(b.endTs)}';
    final title =
        resolveVehicleName?.call(b.vehicleId) ??
        'Vehículo ${b.vehicleId.substring(0, 8)}';

    return TripItem(
      title: title,
      date: range,
      // si TripItem tiene más campos, agrégalos aquí
    );
  }
}
