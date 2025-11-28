import 'package:flutter/material.dart';
import '../data/feedback_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  final FeedbackRepository repo;

  int rating = 0;
  String comment = "";
  bool submitting = false;
  bool submitted = false;

  FeedbackViewModel(this.repo);

  void setRating(int r) {
    rating = r;
    notifyListeners();
  }

  void setComment(String c) {
    comment = c;
    notifyListeners();
  }

  Future<void> submit() async {
    if (rating == 0) return;

    submitting = true;
    notifyListeners();

    await repo.submitFeedback(rating: rating, comment: comment);

    submitting = false;
    submitted = true;
    notifyListeners();
  }
}
