// lib/presentation/features/vehicle/view/add_vehicle_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/presentation/features/vehicle/viewmodel/add_vehicle_viewmodel.dart';

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

  void _markStale() {
    context.read<AddVehicleViewModel>().markStale();
  }

  Future<void> _fetchSuggestedPrice() async {
    final y = int.tryParse(_yearC.text);
    final seats = int.tryParse(_seatsC.text);
    final mil = int.tryParse(_mileageC.text);
    final lat = double.tryParse(_latC.text);
    final lng = double.tryParse(_lngC.text);

    await context.read<AddVehicleViewModel>().fetchSuggestedPrice(
      make: _makeC.text,
      model: _modelC.text,
      year: y,
      seats: seats,
      mileage: mil,
      lat: lat,
      lng: lng,
    );
  }

  Future<void> _submit() async {
    final vm = context.read<AddVehicleViewModel>();
    if (!_formKey.currentState!.validate()) return;

    try {
      final ok = await vm.submit(
        title: _titleC.text.trim(),
        make: _makeC.text.trim(),
        model: _modelC.text.trim(),
        year: int.parse(_yearC.text.trim()),
        plate: _plateC.text.trim(),
        seats: int.parse(_seatsC.text.trim()),
        mileage: int.parse(_mileageC.text.trim()),
        lat: double.parse(_latC.text.trim()),
        lng: double.parse(_lngC.text.trim()),
        dailyPrice: double.parse(_priceC.text.trim()),
        imageUrl: _imageUrlC.text.trim().isEmpty
            ? null
            : _imageUrlC.text.trim(),
      );

      if (!mounted) return;
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Vehículo creado y pricing registrado'),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('⚠️ Error: $e')));
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

  @override
  Widget build(BuildContext context) {
    const p = EdgeInsets.symmetric(horizontal: 24.0);
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final vm = context.watch<AddVehicleViewModel>();

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
            value: vm.transmission,
            decoration: _dec(context, 'Transmission'),
            items: const [
              DropdownMenuItem(value: 'AT', child: Text('Automatic')),
              DropdownMenuItem(value: 'MT', child: Text('Manual')),
            ],
            onChanged: (v) =>
                context.read<AddVehicleViewModel>().setTransmission(v ?? 'AT'),
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
            value: vm.fuelType,
            decoration: _dec(context, 'Fuel type'),
            items: const [
              DropdownMenuItem(value: 'gas', child: Text('Gasoline')),
              DropdownMenuItem(value: 'diesel', child: Text('Diesel')),
              DropdownMenuItem(value: 'hybrid', child: Text('Hybrid')),
              DropdownMenuItem(value: 'ev', child: Text('Electric')),
            ],
            onChanged: (v) =>
                context.read<AddVehicleViewModel>().setFuelType(v ?? 'gas'),
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
              onPressed: vm.loading ? null : _submit,
              child: Text(vm.loading ? 'Saving…' : 'Save vehicle'),
            ),
          ),
        ],
      ),
    );

    final suggestCard = _SuggestedPriceCard(
      loading: vm.fetchingSuggest,
      value: vm.suggested,
      reason: vm.reason,
      stale: vm.suggestionStale,
      onRefresh: _fetchSuggestedPrice,
      onApply: () {
        if (vm.suggested != null) {
          _priceC.text = vm.suggested!.toStringAsFixed(2);
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
