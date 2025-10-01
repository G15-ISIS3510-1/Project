import 'package:flutter/material.dart';
import 'package:flutter_app/Home/home_view.dart';
import 'package:flutter_app/Home/host_view.dart';
import 'package:flutter_app/Home/settings/account_view.dart';
import 'package:flutter_app/Home/trips_view.dart';
import 'package:flutter_app/Home/messages_view.dart';
import 'package:flutter_app/data/chat_api.dart';
import 'package:flutter_app/Home/host_home_view.dart';
import 'package:flutter_app/host_mode_provider.dart';
import 'package:provider/provider.dart'; // 👈 tu HostHomeView nuevo
// (luego agregas Messages/Host/Account cuando existan)

void goToTab(
  BuildContext context,
  int index, {
  required ChatApi api,
  required String currentUserId,
}) {
  switch (index) {
    case 0: // Home
      final isHost = context.read<HostModeProvider>().isHostMode;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              isHost ? HostHomeView(currentUserId: currentUserId) : HomeView(),
        ),
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
        MaterialPageRoute(
          builder: (_) => MessagesView(api: api, currentUserId: currentUserId),
        ),
      );
      break;
    case 3:
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const AccountView()),
      );
  }
}
