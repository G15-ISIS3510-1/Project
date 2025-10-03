// lib/presentation/common_widgets/tab_navigation.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/features/home/view/home_view.dart';
import 'package:flutter_app/presentation/features/settings/view/account_view.dart';
import 'package:flutter_app/presentation/features/trips/view/trips_view.dart';
import 'package:flutter_app/presentation/features/messages/view/messages_view.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';
import 'package:flutter_app/presentation/features/host_home/view/host_home_view.dart';
import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';


void goToTab(
  BuildContext context,
  int index, {
  required ChatApi api,
  required String currentUserId,
}) {
  switch (index) {
    case 0:
      {
        final isHost = context.read<HostModeProvider>().isHostMode;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => isHost
                ? HostHomeView(currentUserId: currentUserId)
                : const HomeView(),
          ),
        );
        break;
      }
    case 1:
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
      break;
  }
}
