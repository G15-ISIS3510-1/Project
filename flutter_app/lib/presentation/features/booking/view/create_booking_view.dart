import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/presentation/features/booking/viewmodel/booking_viewmodel.dart';


class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({super.key});

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _vehicleIdC = TextEditingController(text: 'VEH-001');
  final _renterIdC = TextEditingController(text: 'USR-001'); 
  final _hostIdC = TextEditingController(text: 'HST-001');
  final _insurancePlanIdC = TextEditingController(text: 'INS-STD');

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  final _dailyPriceC = TextEditingController(text: '50.0');
  final _totalC = TextEditingController(text: '100.0'); 
  final _subtotalC = TextEditingController(text: '90.0');
  final _feesC = TextEditingController(text: '5.0');
  final _taxesC = TextEditingController(text: '5.0');
  
  @override
  void dispose() {
    _vehicleIdC.dispose();
    _renterIdC.dispose();
    _hostIdC.dispose();
    _insurancePlanIdC.dispose();
    _dailyPriceC.dispose();
    _totalC.dispose();
    _subtotalC.dispose();
    _feesC.dispose();
    _taxesC.dispose();
    super.dispose();
  }

  InputDecoration _dec(BuildContext context, String hint) {
    final t = Theme.of(context);
    final fill = t.colorScheme.surfaceVariant.withOpacity(
      t.brightness == Brightness.dark ? 0.3 : 1.0,
    );
    final onSurface = t.colorScheme.onSurface.withOpacity(0.12);

    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: fill,
      hintStyle: TextStyle(color: t.colorScheme.onSurface.withOpacity(0.6)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: onSurface),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: onSurface),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: t.colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _selectDateTime(
    bool isStart,
    StateSetter setter,
  ) async {
    final now = DateTime.now();
    
    final date = await showDatePicker(
      context: context,
      initialDate: isStart ? (_startDateTime ?? now) : (_endDateTime ?? now.add(const Duration(days: 1))),
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? (_startDateTime ?? now) : (_endDateTime ?? now)),
    );
    if (time == null) return;

    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setter(() {
      if (isStart) {
        _startDateTime = selectedDateTime;
      } else {
        _endDateTime = selectedDateTime;
      }
    });
  }

  Future<void> _createBooking() async {
    final vm = Provider.of<BookingViewModel>(context, listen: false);

    if (!_formKey.currentState!.validate()) return;
    
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona ambas fechas/horas de la reserva')),
      );
      return;
    }
    if (_endDateTime!.isBefore(_startDateTime!) || _endDateTime!.isAtSameMomentAs(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de fin debe ser estrictamente posterior a la de inicio')),
      );
      return;
    }

    final bookingData = BookingCreateModel(
      vehicleId: _vehicleIdC.text.trim(),
      renterId: _renterIdC.text.trim(),
      hostId: _hostIdC.text.trim(),
      insurancePlanId: _insurancePlanIdC.text.trim(),
      startTs: _startDateTime!.toIso8601String(), 
      endTs: _endDateTime!.toIso8601String(),
      
      dailyPriceSnapshot: double.parse(_dailyPriceC.text),
      insuranceDailyCostSnapshot: 5.0, 
      subtotal: double.parse(_subtotalC.text),
      fees: double.parse(_feesC.text),
      taxes: double.parse(_taxesC.text),
      total: double.parse(_totalC.text),
      currency: 'USD',
    );

    final success = await vm.createBooking(bookingData);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reserva creada exitosamente!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${vm.errorMessage}', maxLines: 2)),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, String label, {TextInputType keyboardType = TextInputType.text, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
      decoration: _dec(context, hint).copyWith(labelText: label),
      keyboardType: keyboardType,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return '$label es requerido';
        if (keyboardType == TextInputType.number) {
          if (double.tryParse(v) == null) return 'Debe ser un número válido';
        }
        return null;
      },
    );
  }

  Widget _buildDateTimePicker({
    required bool isStart,
    required String label,
    required DateTime? dateTime,
    required Function(StateSetter) onTap,
  }) {
    final dateFormat = DateFormat('EEE, d MMM yyyy - HH:mm');

    return StatefulBuilder(
      builder: (context, setState) {
        return InkWell(
          onTap: () => onTap(setState),
          child: InputDecorator(
            decoration: _dec(context, 'Seleccionar').copyWith(
              labelText: label,
              suffixIcon: const Icon(Icons.calendar_today),
            ),
            child: Text(
              dateTime != null
                  ? dateFormat.format(dateTime!)
                  : 'Selecciona fecha y hora',
              style: TextStyle(
                color: dateTime != null
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crear Nueva Reserva'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Datos de la Reserva',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20.0),

                  Text('IDs (Valores de Prueba)', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16.0),
                  _buildTextField(_vehicleIdC, 'Vehicle ID', 'ID del Vehículo', readOnly: true),
                  const SizedBox(height: 16.0),
                  _buildTextField(_renterIdC, 'Renter ID', 'ID del Inquilino', readOnly: true),
                  const SizedBox(height: 16.0),
                  _buildTextField(_hostIdC, 'Host ID', 'ID del Anfitrión', readOnly: true),
                  const SizedBox(height: 32.0),

                  Text('Rango de Tiempo', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16.0),

                  _buildDateTimePicker(
                    isStart: true,
                    label: 'Fecha y Hora de Inicio',
                    dateTime: _startDateTime,
                    onTap: (setter) => _selectDateTime(true, setter),
                  ),
                  const SizedBox(height: 16.0),

                  _buildDateTimePicker(
                    isStart: false,
                    label: 'Fecha y Hora de Fin',
                    dateTime: _endDateTime,
                    onTap: (setter) => _selectDateTime(false, setter),
                  ),
                  const SizedBox(height: 32.0),

                  Text('Detalles del Precio (Snapshots)', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16.0),
                  _buildTextField(_dailyPriceC, 'Daily Price', 'Precio Diario', keyboardType: TextInputType.number),
                  const SizedBox(height: 16.0),
                  _buildTextField(_subtotalC, 'Subtotal', 'Subtotal', keyboardType: TextInputType.number),
                  const SizedBox(height: 16.0),
                  _buildTextField(_feesC, 'Fees', 'Comisiones', keyboardType: TextInputType.number),
                  const SizedBox(height: 16.0),
                  _buildTextField(_taxesC, 'Taxes', 'Impuestos', keyboardType: TextInputType.number),
                  const SizedBox(height: 16.0),
                  _buildTextField(_totalC, 'Total', 'Total a Pagar', keyboardType: TextInputType.number, readOnly: true),
                  const SizedBox(height: 32.0),

                  Consumer<BookingViewModel>(
                    builder: (context, vm, child) {
                      return FilledButton(
                        onPressed: vm.isLoading ? null : _createBooking,
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                        child: Text(
                          vm.isLoading ? 'Creando Reserva…' : 'Confirmar Reserva',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 40.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}