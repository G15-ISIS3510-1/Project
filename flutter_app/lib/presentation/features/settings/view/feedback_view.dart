import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/feedback_viewmodel.dart';
import '../../analytics/time_analytics/data/time_tracker.dart';
import '../../analytics/time_analytics/data/time_storage.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({super.key});

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView> {
  @override
  void initState() {
    super.initState();
    TimeTracker.start("feedback_view");
  }

  @override
  void dispose() {
    final record = TimeTracker.stop();
    if (record != null) TimeStorage.save(record);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FeedbackViewModel>();
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: scheme.onSurface),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 12),

              Text(
                "Rate Your Experience",
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              Text("How would you rate the app?", style: text.bodyLarge),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final index = i + 1;
                  return IconButton(
                    onPressed: () => vm.setRating(index),
                    icon: Icon(
                      Icons.star,
                      size: 36,
                      color: index <= vm.rating
                          ? Colors.amber
                          : scheme.outlineVariant,
                    ),
                  );
                }),
              ),

              const SizedBox(height: 28),

              Text("Any comments?", style: text.bodyLarge),
              const SizedBox(height: 12),

              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Write something…",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: vm.setComment,
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: vm.submitting ? null : vm.submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.black,
                  ),
                  child: vm.submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Submit Feedback",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              if (vm.submitted)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Thank you! Your feedback has been submitted.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
