import 'package:flutter/material.dart';
import 'package:flutter_app/Home/home_view.dart';
import 'package:flutter_app/Home/trips_view.dart';
import 'package:flutter_app/Home/messages_view.dart';
// (luego agregas Messages/Host/Account cuando existan)

void goToTab(BuildContext context, int index) {
  switch (index) {
    case 0: // Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
      break;
    case 1: // Trips
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TripsView()),
      );
      break;
    case 2:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MessagesView()),
      );
    // case 3: Navigator.pushReplacement(... HostView());
    // case 4: Navigator.pushReplacement(... AccountView());
  }
}
