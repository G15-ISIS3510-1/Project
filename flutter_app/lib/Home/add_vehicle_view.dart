import 'package:flutter/material.dart';
import 'package:flutter_app/features/vehicles/vehicle_service.dart';

class AddVehicleView extends StatefulWidget {
  const AddVehicleView({super.key});

  @override
  State<AddVehicleView> createState() => _AddVehicleViewState();
}

class _AddVehicleViewState extends State<AddVehicleView> {
  final _formKey = GlobalKey<FormState>();

  final _titleC = TextEditingController();
  final _makeC = TextEditingController();
  final _modelC = TextEditingController();
  final _yearC = TextEditingController();
  final _priceC = TextEditingController();
  final _imageUrlC = TextEditingController();
  final _plateC = TextEditingController();
  final _seatsC = TextEditingController(text: '5');
  final _mileageC = TextEditingController(text: '0');
  final _latC = TextEditingController(text: '0');
  final _lngC = TextEditingController(text: '0');

  String _transmission = 'AT'; // AT = automática, MT = manual
  String _fuelType = 'gas'; // gasoline|diesel|hybrid|ev
  String _status = 'active'; // active|inactive|pending_review
  bool _loading = false;

  @override
  void dispose() {
    _titleC.dispose();
    _makeC.dispose();
    _modelC.dispose();
    _yearC.dispose();
    _priceC.dispose();
    _imageUrlC.dispose();
    _plateC.dispose();
    _seatsC.dispose();
    _mileageC.dispose();
    _latC.dispose();
    _lngC.dispose();
    super.dispose();
  }

  InputDecoration _dec(BuildContext context, String hint) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor:
          theme.inputDecorationTheme.fillColor ??
          (theme.brightness == Brightness.dark
              ? const Color(0xFF1C2230)
              : scheme.surface),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await VehicleService.createVehicle(
        title: _titleC.text.trim(),
        make: _makeC.text.trim(),
        model: _modelC.text.trim(),
        year: int.parse(_yearC.text.trim()),
        transmission: _transmission,
        pricePerDay: double.parse(_priceC.text.trim()),
        imageUrl: _imageUrlC.text.trim().isEmpty
            ? null
            : _imageUrlC.text.trim(),
        plate: _plateC.text.trim().toUpperCase(),
        seats: int.parse(_seatsC.text.trim()),
        fuelType: _fuelType,
        mileage: int.parse(_mileageC.text.trim()),
        status: _status,
        lat: double.parse(_latC.text.trim()),
        lng: double.parse(_lngC.text.trim()),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Vehicle + pricing created')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const p = EdgeInsets.symmetric(horizontal: 24.0);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        // Deja que el tema defina colores/elevación:
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          child: Padding(
            padding: p,
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleC,
                    decoration: _dec(
                      context,
                      'Title (e.g., Toyota Corolla 2020)',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _makeC,
                    decoration: _dec(context, 'Make (e.g., Toyota)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _modelC,
                    decoration: _dec(context, 'Model (e.g., Corolla)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _yearC,
                    decoration: _dec(context, 'Year (e.g., 2020)'),
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final y = int.tryParse(v ?? '');
                      if (y == null ||
                          y < 1980 ||
                          y > DateTime.now().year + 1) {
                        return 'Invalid year';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // Transmission
                  DropdownButtonFormField<String>(
                    value: _transmission,
                    decoration: _dec(context, 'Transmission'),
                    items: const [
                      DropdownMenuItem(value: 'AT', child: Text('Automatic')),
                      DropdownMenuItem(value: 'MT', child: Text('Manual')),
                    ],
                    onChanged: (v) => setState(() => _transmission = v ?? 'AT'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _priceC,
                    decoration: _dec(context, 'Price per day (USD)'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) {
                      final p = double.tryParse(v ?? '');
                      if (p == null || p <= 0) return 'Invalid price';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _plateC,
                    decoration: _dec(context, 'Plate (e.g., ABC123)'),
                    textCapitalization: TextCapitalization.characters,
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _seatsC,
                    decoration: _dec(context, 'Seats (e.g., 5)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') == null)
                        ? 'Invalid seats'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _fuelType,
                    decoration: _dec(context, 'Fuel type'),
                    items: const [
                      DropdownMenuItem(value: 'gas', child: Text('Gasoline')),
                      DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
                      DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
                      DropdownMenuItem(value: 'ev', child: Text('Electric')),
                    ],
                    onChanged: (v) => setState(() => _fuelType = v ?? 'gas'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _mileageC,
                    decoration: _dec(context, 'Mileage (km)'),
                    keyboardType: TextInputType.number,
                    validator: (v) => (int.tryParse(v ?? '') == null)
                        ? 'Invalid mileage'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _dec(context, 'Status'),
                    items: const [
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Available'),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Unavailable'),
                      ),
                      DropdownMenuItem(
                        value: 'pending_review',
                        child: Text('Pending Review'),
                      ),
                    ],
                    onChanged: (v) => setState(() => _status = v ?? 'active'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _latC,
                    decoration: _dec(context, 'Latitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (double.tryParse(v ?? '') == null)
                        ? 'Invalid latitude'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _lngC,
                    decoration: _dec(context, 'Longitude'),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    validator: (v) => (double.tryParse(v ?? '') == null)
                        ? 'Invalid longitude'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _imageUrlC,
                    decoration: _dec(context, 'Image URL (optional)'),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: ButtonStyle(
                        minimumSize: const MaterialStatePropertyAll(
                          Size.fromHeight(48),
                        ),
                        shape: MaterialStatePropertyAll(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        backgroundColor: MaterialStateProperty.resolveWith((
                          states,
                        ) {
                          final scheme = Theme.of(context).colorScheme;
                          if (states.contains(MaterialState.disabled)) {
                            return scheme.onSurface.withOpacity(0.12);
                          }
                          return scheme.primary;
                        }),
                        foregroundColor: MaterialStatePropertyAll(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                      child: Text(_loading ? 'Saving…' : 'Save vehicle'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
