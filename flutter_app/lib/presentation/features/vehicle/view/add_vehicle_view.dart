// lib/presentation/features/vehicle/view/add_vehicle_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart';
import 'package:flutter_app/main.dart' show AuthProvider;


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

  String _transmission = 'AT'; // AT | MT
  String _fuelType = 'gas'; // gas|diesel|hybrid|ev
  String _status = 'active'; // active|inactive|pending_review
  bool _loading = false;

  // --- IA pricing ---
  double? _suggested;
  String? _reason;
  bool _fetchingSuggest = false;
  bool _suggestionStale = false;

  void _markStale() {
    if (!_suggestionStale) setState(() => _suggestionStale = true);
  }

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

  Future<void> _fetchSuggestedPrice() async {
    final token = context.read<AuthProvider?>()?.token;
    if (token == null) return;

    final form = <String, dynamic>{};
    void putIf(String k, String v) {
      if (v.trim().isNotEmpty) form[k] = v.trim();
    }

    putIf('make', _makeC.text);
    putIf('model', _modelC.text);

    final y = int.tryParse(_yearC.text);
    if (y != null) form['year'] = y;

    form['transmission'] = _transmission;
    form['fuel_type'] = _fuelType;

    final seats = int.tryParse(_seatsC.text);
    if (seats != null) form['seats'] = seats;

    final mil = int.tryParse(_mileageC.text);
    if (mil != null) form['mileage'] = mil;

    final lat = double.tryParse(_latC.text);
    if (lat != null) form['lat'] = lat;

    final lng = double.tryParse(_lngC.text);
    if (lng != null) form['lng'] = lng;

    if (form.isEmpty) return;

    setState(() => _fetchingSuggest = true);
    try {
      final res = await PricingService.suggestPrice(form: form);
      if (!mounted) return;
      setState(() {
        _suggested = res?.value;
        _reason = res?.reasoning;
        _suggestionStale = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _suggested = null;
        _reason = null;
      });
    } finally {
      if (mounted) setState(() => _fetchingSuggest = false);
    }
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

  // --- helper para extraer el ID que devuelva tu VehicleService
  String? _extractVehicleId(dynamic created) {
    try {
      if (created == null) return null;
      // Caso: objeto con campo id
      final idField = (created as dynamic).id;
      if (idField is String && idField.isNotEmpty) return idField;
    } catch (_) {}
    // Caso: Map
    if (created is Map) {
      final id = created['id'] ?? created['vehicle_id'] ?? created['uuid'];
      if (id is String && id.isNotEmpty) return id;
    }
    // Caso: String directo
    if (created is String && created.isNotEmpty) return created;
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final price = double.parse(_priceC.text.trim());

      // 1) Crear vehículo
      final created = await VehicleService.createVehicle(
        title: _titleC.text.trim(),
        make: _makeC.text.trim(),
        model: _modelC.text.trim(),
        year: int.parse(_yearC.text.trim()),
        transmission: _transmission,
        // Puedes enviar pricePerDay aquí si tu API lo admite,
        // pero igual creamos el pricing explícitamente abajo.
        pricePerDay: price,
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

      // 2) Obtener vehicleId sin asumir tipo de retorno
      final vehicleId = _extractVehicleId(created);
      if (vehicleId == null) {
        throw Exception('No se pudo obtener el vehicleId del createVehicle().');
      }

      // 3) Crear/Upsert del pricing para evitar el 404 en GET /api/pricing/vehicle/{id}
      await PricingService.create(
        vehicleId,
        double.parse(_priceC.text.trim()),
        minDays: 1, // ajusta tus reglas
        maxDays: 30, // idem
        currency: 'USD',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Vehículo creado y pricing registrado')),
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
    final text = Theme.of(context).textTheme;

    final form = Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _titleC,
            decoration: _dec(context, 'Title (e.g., Toyota Corolla 2020)'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _makeC,
            decoration: _dec(context, 'Make (e.g., Toyota)'),
            onChanged: (_) => _markStale(),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _modelC,
            decoration: _dec(context, 'Model (e.g., Corolla)'),
            onChanged: (_) => _markStale(),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _yearC,
            decoration: _dec(context, 'Year (e.g., 2020)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _markStale(),
            validator: (v) {
              final y = int.tryParse(v ?? '');
              if (y == null || y < 1980 || y > DateTime.now().year + 1) {
                return 'Invalid year';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          DropdownButtonFormField<String>(
            value: _transmission,
            decoration: _dec(context, 'Transmission'),
            items: const [
              DropdownMenuItem(value: 'AT', child: Text('Automatic')),
              DropdownMenuItem(value: 'MT', child: Text('Manual')),
            ],
            onChanged: (v) {
              setState(() => _transmission = v ?? 'AT');
              _markStale();
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _priceC,
            decoration: _dec(context, 'Price per day (USD)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
            onChanged: (_) => _markStale(),
            validator: (v) =>
                (int.tryParse(v ?? '') == null) ? 'Invalid seats' : null,
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
            onChanged: (v) {
              setState(() => _fuelType = v ?? 'gas');
              _markStale();
            },
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _mileageC,
            decoration: _dec(context, 'Mileage (km)'),
            keyboardType: TextInputType.number,
            onChanged: (_) => _markStale(),
            validator: (v) =>
                (int.tryParse(v ?? '') == null) ? 'Invalid mileage' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _latC,
            decoration: _dec(context, 'Latitude'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _markStale(),
            validator: (v) =>
                (double.tryParse(v ?? '') == null) ? 'Invalid latitude' : null,
          ),
          const SizedBox(height: 12),

          TextFormField(
            controller: _lngC,
            decoration: _dec(context, 'Longitude'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => _markStale(),
            validator: (v) =>
                (double.tryParse(v ?? '') == null) ? 'Invalid longitude' : null,
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
              child: Text(_loading ? 'Saving…' : 'Save vehicle'),
            ),
          ),
        ],
      ),
    );

    final suggestCard = _SuggestedPriceCard(
      loading: _fetchingSuggest,
      value: _suggested,
      reason: _reason,
      stale: _suggestionStale,
      onRefresh: _fetchSuggestedPrice,
      onApply: () {
        if (_suggested != null) {
          _priceC.text = _suggested!.toStringAsFixed(2);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('AI price applied')));
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Vehicle'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation ?? 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            final wide = c.maxWidth >= 900;
            return SingleChildScrollView(
              padding: const EdgeInsets.only(top: 16, bottom: 24),
              child: Padding(
                padding: p,
                child: wide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: form),
                          const SizedBox(width: 24),
                          SizedBox(width: 320, child: suggestCard),
                        ],
                      )
                    : Column(
                        children: [
                          suggestCard,
                          const SizedBox(height: 16),
                          form,
                        ],
                      ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestedPriceCard extends StatelessWidget {
  final bool loading;
  final double? value;
  final String? reason;
  final bool stale;
  final VoidCallback onRefresh;
  final VoidCallback onApply;

  const _SuggestedPriceCard({
    required this.loading,
    required this.value,
    required this.reason,
    required this.stale,
    required this.onRefresh,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AI suggested price',
              style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),

            if (stale && !loading) ...[
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Values changed — tap refresh to update.',
                      style: text.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            if (loading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              Text(
                'Calculating…',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ] else if (value != null) ...[
              Row(
                children: [
                  Text(
                    '\$${value!.toStringAsFixed(2)}',
                    style: text.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: scheme.primary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Refresh',
                    onPressed: loading ? null : onRefresh,
                    icon: Icon(
                      Icons.refresh,
                      color: stale ? scheme.primary : scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (reason != null && reason!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  reason!,
                  style: text.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: value == null || loading ? null : onApply,
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Apply'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ] else ...[
              Text(
                'Get an AI price suggestion',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: loading ? null : onRefresh,
                  icon: const Icon(Icons.lightbulb),
                  label: const Text('Suggest price'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
