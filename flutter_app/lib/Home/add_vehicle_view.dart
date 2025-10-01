// lib/features/vehicles/add_vehicle_view.dart
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

  String _transmission = 'AT'; // AT = automática, MT = manual
  bool _loading = false;

  @override
  void dispose() {
    _titleC.dispose();
    _makeC.dispose();
    _modelC.dispose();
    _yearC.dispose();
    _priceC.dispose();
    _imageUrlC.dispose();
    super.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide.none,
    ),
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final created = await VehicleService.createVehicle(
        title: _titleC.text.trim(),
        make: _makeC.text.trim(),
        model: _modelC.text.trim(),
        year: int.tryParse(_yearC.text.trim()),
        transmission: _transmission, // 'AT' | 'MT'
        pricePerDay: double.parse(_priceC.text.trim()),
        // imageUrl: _imageUrlC.text.trim().isEmpty ? null : _imageUrlC.text.trim(), // si tu API lo soporta
      );

      if (!mounted) return;
      if (created) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Vehicle created')));
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Could not create vehicle')),
        );
      }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
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
                    decoration: _dec('Title (e.g., Toyota Corolla 2020)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _makeC,
                    decoration: _dec('Make (e.g., Toyota)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _modelC,
                    decoration: _dec('Model (e.g., Corolla)'),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _yearC,
                    decoration: _dec('Year (e.g., 2020)'),
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
                    decoration: _dec('Transmission'),
                    items: const [
                      DropdownMenuItem(value: 'AT', child: Text('Automatic')),
                      DropdownMenuItem(value: 'MT', child: Text('Manual')),
                    ],
                    onChanged: (v) => setState(() => _transmission = v ?? 'AT'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _priceC,
                    decoration: _dec('Price per day (USD)'),
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
                    controller: _imageUrlC,
                    decoration: _dec('Image URL (optional)'),
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _loading ? 'Saving…' : 'Save vehicle',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
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
