import 'package:flutter/material.dart';
import 'package:flutter_app/Home/host_view.dart';
import 'package:flutter_app/Home/settings/account_view.dart';
import 'package:flutter_app/Home/widgets/bottom_bar.dart';
import 'package:flutter_app/Home/home_view.dart';
import 'package:flutter_app/Home/trips_view.dart';
import 'package:flutter_app/Home/messages_view.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const double kBarHeight = 76;
  static const double kBarVPad = 12;

  // Mantén los tabs aquí; IndexedStack preserva su estado.
  final _tabs = const <Widget>[
    HomeView(),
    TripsView(),
    MessagesView(),
    HostView(),
    AccountView(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      extendBody: true, // deja pasar contenido detrás del bar (glass)
      body: Stack(
        children: [
          // Contenido de tabs (no se recrea el BottomBar)
          Positioned.fill(
            child: IndexedStack(index: _index, children: _tabs),
          ),

          // Bottom bar, una sola instancia
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, kBarVPad),
                child: BottomBar(
                  currentIndex: _index,
                  items: const [
                    BottomBarItem(Icons.home_rounded, 'Home'),
                    BottomBarItem(Icons.navigation_rounded, 'Trip'),
                    BottomBarItem(Icons.chat_bubble_rounded, 'Messages'),
                    BottomBarItem(Icons.dashboard_customize_rounded, 'Host'),
                    BottomBarItem(Icons.person_rounded, 'Account'),
                  ],
                  onTap: (i) => setState(() => _index = i),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stub extends StatelessWidget {
  final String label;
  const _Stub(this.label);

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(label));
  }
}
