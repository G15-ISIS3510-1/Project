import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/contact_us_viewmodel.dart';

import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';

class ContactUsView extends StatefulWidget {
  const ContactUsView({super.key});

  @override
  State<ContactUsView> createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  @override
  void initState() {
    super.initState();
    TimeTracker.start("contact_us_view");
  }

  @override
  void dispose() {
    final rec = TimeTracker.stop();
    if (rec != null) TimeStorage.save(rec);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ContactUsViewModel>();

    const p24 = 24.0;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(p24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close, color: scheme.onSurface),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          'Contact Us',
                          style: text.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(thickness: 2, color: scheme.outlineVariant),
                        const SizedBox(height: 20),

                        if (vm.sent)
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: const Text(
                              "Your message has been sent successfully!",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                        if (!vm.sent) ...[
                          _field("Full Name", vm.setName),
                          const SizedBox(height: 16),

                          _field("Email Address", vm.setEmail,
                              keyboard: TextInputType.emailAddress),
                          const SizedBox(height: 16),

                          _field("Phone (optional)", vm.setPhone,
                              keyboard: TextInputType.phone),
                          const SizedBox(height: 16),

                          _field("Subject", vm.setSubject),
                          const SizedBox(height: 16),

                          _field("Message", vm.setMessage, maxLines: 6),
                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: vm.loading ? null : vm.send,
                              child: vm.loading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white)
                                  : const Text("Submit"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          if (vm.usedCache)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                color: Colors.orange.shade100,
                child: const Text(
                  "Offline — Message queued locally",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    Function(String) onChanged, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      onChanged: onChanged,
      keyboardType: keyboard,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
