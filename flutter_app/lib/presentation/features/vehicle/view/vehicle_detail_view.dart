// imports: NO necesitas repos/chat aquí
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/presentation/features/vehicle/viewmodel/vehicle_detail_viewmodel.dart';
import 'package:flutter_app/presentation/features/booking/view/create_booking_view.dart';

class VehicleDetailView extends StatelessWidget {
  const VehicleDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VehicleDetailViewModel>();
    final v = vm.vehicle;

    return Scaffold(
      appBar: AppBar(title: Text(v.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${v.make} • ${v.model} • ${v.year}'),
            Text('Trans: ${v.transmissionLabel} • Seats: ${v.seats}'),
            const Spacer(),
            FilledButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CreateBookingScreen(
                      initialVehicleId: v.vehicle_id,
                      initialHostId: v.ownerId,
                      initialDailyPrice: vm.dailyPrice,
                      // initialRenterId: context.read<AuthProvider>().userId,
                    ),
                  ),
                );
              },
              child: const Text('Elegir fechas'),
            ),
          ],
        ),
      ),
    );
  }
}
