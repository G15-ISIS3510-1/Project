// lib/presentation/features/vehicle/viewmodel/vehicle_detail_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/models/vehicle_model.dart';

class VehicleDetailViewModel extends ChangeNotifier {
  VehicleDetailViewModel({required this.vehicle, required this.dailyPrice});

  final Vehicle vehicle;
  final double dailyPrice;
}
