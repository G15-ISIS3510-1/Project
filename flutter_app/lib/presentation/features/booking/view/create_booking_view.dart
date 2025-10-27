// lib/presentation/features/booking/view/create_booking_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/app/utils/result.dart';
import 'package:flutter_app/data/models/availability_model.dart';
import 'package:flutter_app/data/repositories/availability_repository.dart';
import 'package:flutter_app/data/sources/remote/availability_remote_source.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/main.dart' show AuthProvider;
import 'package:flutter_app/data/models/booking_create_model.dart';
import 'package:flutter_app/presentation/features/booking/viewmodel/booking_viewmodel.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart'; // BookingService
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({
    super.key,
    required this.initialVehicleId,
    required this.initialHostId,
    this.initialDailyPrice,
  });

  final String initialVehicleId;
  final String initialHostId;
  final double? initialDailyPrice;

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();

  List<AvailabilityWindow> _slots = [];
  bool _loadingSlots = true;
  String? _slotsError;
  AvailabilityWindow? _slotForStart; // slot que contiene el inicio elegido

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  late final TextEditingController _dailyPriceC;
  final _totalC = TextEditingController(text: '0.0');
  final _subtotalC = TextEditingController(text: '0.0');
  final _feesC = TextEditingController(text: '0.0');
  final _taxesC = TextEditingController(text: '0.0');
  final _insurancePlanIdC = TextEditingController(text: '');

  late final AvailabilityRepository _availabilityRepo;

  @override
  void initState() {
    super.initState();
    _dailyPriceC = TextEditingController(
      text: (widget.initialDailyPrice ?? 50).toStringAsFixed(2),
    );

    _availabilityRepo = AvailabilityRepositoryImpl(
      remote: AvailabilityService(),
    );

    if (widget.initialVehicleId.isNotEmpty) {
      _loadAvailability(widget.initialVehicleId);
    } else {
      _loadingSlots = false; // sin vehicle id, no bloqueamos fechas
    }
  }

  Future<void> _loadAvailability(String vehicleId) async {
    setState(() {
      _loadingSlots = true;
      _slotsError = null;
      _slots = [];
    });

    try {
      const int pageSize = 100;
      int skip = 0;
      bool hasMore = true;
      final List<AvailabilityWindow> acc = [];

      while (hasMore) {
        final Result<AvailabilityPage> r = await _availabilityRepo
            .listByVehicle(vehicleId, skip: skip, limit: pageSize);

        if (r.isErr) {
          // si es la primera página, mostramos el error
          if (acc.isEmpty) throw Exception(r.errOrNull);
          // si ya acumulamos algo, salimos
          break;
        }

        final page = r.okOrNull!;
        acc.addAll(page.items);
        hasMore = page.hasMore;

        if (hasMore) skip += pageSize;
      }

      // Ajuste de zona horaria y filtro por tipo
      final fixed = acc
          .map(
            (w) => AvailabilityWindow(
              availability_id: w.availability_id,
              vehicle_id: w.vehicle_id,
              start: w.start.toLocal(),
              end: w.end.toLocal(),
              type: w.type,
              notes: w.notes,
            ),
          )
          .where((s) => s.type == 'available')
          .toList(growable: false);

      setState(() {
        _slots = fixed;
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() {
        _slotsError = 'No se pudo cargar disponibilidad: $e';
        _loadingSlots = false;
      });
    }
  }

  @override
  void dispose() {
    _insurancePlanIdC.dispose();
    _dailyPriceC.dispose();
    _totalC.dispose();
    _subtotalC.dispose();
    _feesC.dispose();
    _taxesC.dispose();
    super.dispose();
  }

  void _recalcTotals() {
    if (_startDateTime == null || _endDateTime == null) return;
    final dp = double.tryParse(_dailyPriceC.text) ?? 0.0;

    // al menos 1 día, redondeo hacia arriba por horas
    final hours = _endDateTime!.difference(_startDateTime!).inHours;
    final days = (hours / 24).ceil().clamp(1, 365);
    final subtotal = dp * days;
    final fees = subtotal * 0.05; // tu regla
    final taxes = subtotal * 0.10; // tu regla
    final total = subtotal + fees + taxes;

    _subtotalC.text = subtotal.toStringAsFixed(2);
    _feesC.text = fees.toStringAsFixed(2);
    _taxesC.text = taxes.toStringAsFixed(2);
    _totalC.text = total.toStringAsFixed(2);
    setState(() {});
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

  bool _dateTouchesAnySlot(DateTime d) {
    if (_slots.isEmpty) return true; // si no hay slots, no bloqueamos el día
    final dayStart = DateTime(d.year, d.month, d.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    // Si el slot se cruza con ese día, habilitamos el día
    return _slots.any(
      (s) => s.start.isBefore(dayEnd) && s.end.isAfter(dayStart),
    );
  }

  AvailabilityWindow? _slotContaining(DateTime dt) {
    for (final s in _slots) {
      final inside =
          !dt.isBefore(s.start) && dt.isBefore(s.end); // [start, end)
      if (inside) return s;
    }
    return null;
  }

  bool _slotContainsRange(AvailabilityWindow s, DateTime a, DateTime b) {
    return !a.isBefore(s.start) && b.isBefore(s.end); // [a,b] dentro del slot
  }

  Future<void> _pickDateTime(bool isStart, StateSetter setter) async {
    if (_loadingSlots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cargando disponibilidad...')),
      );
      return;
    }
    if (_slotsError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_slotsError!)));
      return;
    }

    final now = DateTime.now();

    // 1) Elegir fecha (habilitamos solo días que tocan slots)
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDateTime ?? now)
          : (_endDateTime ?? now.add(const Duration(days: 1))),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      selectableDayPredicate: _dateTouchesAnySlot, // 👈 aquí se bloquean días
    );
    if (pickedDate == null) return;

    // 2) Elegir hora (no se puede restringir visualmente)
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        isStart ? (_startDateTime ?? now) : (_endDateTime ?? now),
      ),
    );
    if (pickedTime == null) return;

    final picked = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    // 3) Validación de pertenencia al slot
    if (_slots.isNotEmpty) {
      final slot = _slotContaining(picked);
      if (slot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La hora elegida no está dentro de la disponibilidad.',
            ),
          ),
        );
        return;
      }

      if (isStart) {
        setter(() {
          _startDateTime = picked;
          _slotForStart = slot;
        });

        // si ya había fin, valida que siga en el mismo slot y dentro del rango
        if (_endDateTime != null &&
            (!_slotContainsRange(slot, _startDateTime!, _endDateTime!))) {
          setter(() {
            _endDateTime = null; // invalidamos fin
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El fin salió del bloque de disponibilidad. Vuelve a elegir fin.',
              ),
            ),
          );
        }
      } else {
        // Fin: necesita inicio válido antes
        if (_startDateTime == null || _slotForStart == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Primero elige la fecha de inicio')),
          );
          return;
        }
        if (!picked.isAfter(_startDateTime!)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Fin debe ser posterior al inicio')),
          );
          return;
        }
        // Mismo slot que el inicio y dentro del rango del slot
        if (slot.availability_id != _slotForStart!.availability_id ||
            !_slotContainsRange(_slotForStart!, _startDateTime!, picked)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Inicio y fin deben quedar dentro del mismo bloque de disponibilidad.',
              ),
            ),
          );
          return;
        }

        setter(() {
          _endDateTime = picked;
        });
      }
    } else {
      // Sin slots (no llegaron o 404): permite elegir como antes (puede fallar en backend)
      setter(() {
        if (isStart) {
          _startDateTime = picked;
        } else {
          _endDateTime = picked;
        }
      });
    }

    _recalcTotals();
  }

  Widget _tf(
    TextEditingController c,
    String hint,
    String label, {
    TextInputType kt = TextInputType.text,
    bool ro = false,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: c,
      readOnly: ro,
      keyboardType: kt,
      decoration: _dec(context, hint).copyWith(labelText: label),
      validator: (v) {
        if (ro) return null; // campos de solo lectura no validan
        if (v == null || v.trim().isEmpty) return '$label es requerido';
        if (kt == TextInputType.number ||
            kt is TextInputType &&
                (kt == const TextInputType.numberWithOptions(decimal: true))) {
          if (double.tryParse(v!) == null) {
            return 'Debe ser un número válido';
          }
        }
        return null;
      },
      onChanged: onChanged,
    );
  }

  Future<void> _submit() async {
    final vm = context.read<BookingViewModel>();

    if (!_formKey.currentState!.validate()) return;
    if (_startDateTime == null || _endDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona fechas/horas de inicio y fin'),
        ),
      );
      return;
    }
    if (!_endDateTime!.isAfter(_startDateTime!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fin debe ser posterior al inicio')),
      );
      return;
    }

    final renterId = context.read<AuthProvider>().userId;
    if (renterId == null || renterId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para reservar')),
      );
      return;
    }

    final vehicleId = widget.initialVehicleId;
    final hostId = widget.initialHostId;

    final hours = _endDateTime!.difference(_startDateTime!).inHours;
    final days = (hours / 24).ceil().clamp(1, 365);
    final daily = double.tryParse(_dailyPriceC.text) ?? 0.0;
    final subtotal = (days * daily).toDouble();
    final fees = double.tryParse(_feesC.text) ?? 0;
    final taxes = double.tryParse(_taxesC.text) ?? 0;
    final total = subtotal + fees + taxes;

    final booking = BookingCreateModel(
      vehicleId: vehicleId,
      renterId: renterId, // debe coincidir con el token (backend lo exige)
      hostId: hostId, // debe coincidir con owner del vehículo
      insurancePlanId: _insurancePlanIdC.text.trim().isEmpty
          ? null
          : _insurancePlanIdC.text.trim(),
      startTs: _startDateTime!.toUtc().toIso8601String(),
      endTs: _endDateTime!.toUtc().toIso8601String(),
      dailyPriceSnapshot: daily,
      insuranceDailyCostSnapshot: null, // ponlo si tienes ese costo
      subtotal: subtotal,
      fees: fees,
      taxes: taxes,
      total: total,
      currency: 'USD',
    );

    final ok = await vm.createBooking(booking);

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reserva creada')));
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(vm.errorMessage ?? 'Error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Puedes crear el VM localmente (como tienes) o inyectarlo global en main.dart.
    final chatRepo = context.read<ChatRepository>();
    final bookingRepo = BookingsRepositoryImpl(BookingService());

    final df = DateFormat('EEE, d MMM yyyy - HH:mm');

    return ChangeNotifierProvider(
      create: (_) =>
          BookingViewModel(bookingsRepo: bookingRepo, chatRepo: chatRepo),
      child: Scaffold(
        appBar: AppBar(title: const Text('Crear Nueva Reserva')),
        body: SafeArea(
          child: _loadingSlots
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Consumer<BookingViewModel>(
                      builder: (context, vm, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_slotsError != null) ...[
                              Text(
                                _slotsError!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Text(
                              'Datos de la Reserva',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 20),

                            // IDs (solo lectura, sin controllers de edición)
                            Text(
                              'IDs',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            _InfoLine(
                              label: 'Vehicle ID',
                              value: widget.initialVehicleId,
                            ),
                            _InfoLine(
                              label: 'Host ID',
                              value: widget.initialHostId,
                            ),
                            _InfoLine(
                              label: 'Renter ID',
                              value: context.read<AuthProvider>().userId ?? '—',
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Rango de Tiempo',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),

                            StatefulBuilder(
                              builder: (context, setSt) => InkWell(
                                onTap: () => _pickDateTime(true, setSt),
                                child: InputDecorator(
                                  decoration: _dec(
                                    context,
                                    'Seleccionar',
                                  ).copyWith(labelText: 'Inicio'),
                                  child: Text(
                                    _startDateTime != null
                                        ? df.format(_startDateTime!)
                                        : 'Selecciona fecha y hora',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            StatefulBuilder(
                              builder: (context, setSt) => InkWell(
                                onTap: () => _pickDateTime(false, setSt),
                                child: InputDecorator(
                                  decoration: _dec(
                                    context,
                                    'Seleccionar',
                                  ).copyWith(labelText: 'Fin'),
                                  child: Text(
                                    _endDateTime != null
                                        ? df.format(_endDateTime!)
                                        : 'Selecciona fecha y hora',
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              'Precio',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 12),
                            _tf(
                              _dailyPriceC,
                              'Daily Price',
                              'Precio Diario',
                              kt: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              onChanged: (_) => _recalcTotals(),
                            ),
                            const SizedBox(height: 12),
                            _tf(
                              _subtotalC,
                              'Subtotal',
                              'Subtotal',
                              kt: TextInputType.number,
                              ro: true,
                            ),
                            const SizedBox(height: 12),
                            _tf(
                              _feesC,
                              'Fees',
                              'Comisiones',
                              kt: TextInputType.number,
                              ro: true,
                            ),
                            const SizedBox(height: 12),
                            _tf(
                              _taxesC,
                              'Taxes',
                              'Impuestos',
                              kt: TextInputType.number,
                              ro: true,
                            ),
                            const SizedBox(height: 12),
                            _tf(
                              _totalC,
                              'Total',
                              'Total a Pagar',
                              kt: TextInputType.number,
                              ro: true,
                            ),

                            const SizedBox(height: 28),
                            FilledButton(
                              onPressed: vm.isLoading ? null : _submit,
                              child: vm.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(),
                                    )
                                  : const Text('Confirmar Reserva'),
                            ),
                            const SizedBox(height: 40),
                          ],
                        );
                      },
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value, style: t.bodyMedium)),
        ],
      ),
    );
  }
}
