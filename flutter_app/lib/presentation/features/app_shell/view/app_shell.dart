// // lib/presentation/features/app_shell/view/app_shell.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_app/data/sources/remote/api_client.dart';
// import 'package:provider/provider.dart';

// import 'package:flutter_app/presentation/features/host_home/view/host_home_view.dart';
// import 'package:flutter_app/presentation/common_widgets/bottom_bar.dart';

// import 'package:flutter_app/presentation/features/home/view/home_view.dart';
// import 'package:flutter_app/presentation/features/trips/view/trips_view.dart';
// import 'package:flutter_app/presentation/features/messages/view/messages_view.dart';
// import 'package:flutter_app/presentation/features/settings/view/account_view.dart';

// import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';
// import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';

// class AppShell extends StatefulWidget {
//   final Api api;
//   final String currentUserId;
//   final int initialIndex;

//   const AppShell({
//     super.key,
//     required this.api,
//     required this.currentUserId,
//     this.initialIndex = 0,
//   });

//   @override
//   State<AppShell> createState() => _AppShellState();
// }

// class _AppShellState extends State<AppShell> {
//   int _index = 0;

//   @override
//   void initState() {
//     super.initState();
//     _index = widget.initialIndex;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isHost = context.watch<HostModeProvider>().isHostMode;

//     final tabs = <Widget>[
//       // 0: Home dinámico
//       isHost
//           ? HostHomeView(currentUserId: widget.currentUserId)
//           : const HomeView(),
//       // 1: Trips
//       const TripsView(),
//       // 2: Messages
//       MessagesView(api: widget.api, currentUserId: widget.currentUserId),
//       // 3: Account
//       const AccountView(),
//     ];

//     // evita out-of-range si cambia la cantidad
//     final safeIndex = _index.clamp(0, tabs.length - 1);

//     return Scaffold(
//       extendBody: true, // necesario para el efecto glass
//       body: Stack(
//         children: [
//           // Contenido
//           Positioned.fill(
//             child: IndexedStack(index: safeIndex, children: tabs),
//           ),
//           // Tu Glass Bottom Bar
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: BottomBar(
//               currentIndex: safeIndex,
//               items: const [
//                 BottomBarItem(Icons.home_rounded, 'Home'),
//                 BottomBarItem(Icons.navigation_rounded, 'Trip'),
//                 BottomBarItem(Icons.chat_bubble_rounded, 'Messages'),
//                 BottomBarItem(Icons.person_rounded, 'Account'),
//               ],
//               onTap: (i) => setState(() => _index = i),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Bottom bar minimalista (puedes seguir usando tu BottomBar si ya la tienes)
// class _BottomBar extends StatelessWidget {
//   final int currentIndex;
//   final ValueChanged<int> onTap;

//   const _BottomBar({required this.currentIndex, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 76,
//       decoration: BoxDecoration(
//         color: Colors.white.withOpacity(0.92),
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 12,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,
//         children: [
//           _item(icon: Icons.home_rounded, label: 'Home', index: 0),
//           _item(icon: Icons.navigation_rounded, label: 'Trip', index: 1),
//           _item(icon: Icons.chat_bubble_rounded, label: 'Messages', index: 2),
//           _item(icon: Icons.person_rounded, label: 'Account', index: 4),
//         ],
//       ),
//     );
//   }

//   Widget _item({
//     required IconData icon,
//     required String label,
//     required int index,
//   }) {
//     final selected = currentIndex == index;
//     return InkWell(
//       borderRadius: BorderRadius.circular(14),
//       onTap: () => onTap(index),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, color: selected ? Colors.black : Colors.black45),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               style: TextStyle(
//                 fontSize: 12,
//                 color: selected ? Colors.black : Colors.black45,
//                 fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// Pantalla cuando Host Mode está apagado: invita a activarlo
// class _HostLanding extends StatelessWidget {
//   const _HostLanding();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(Icons.key_rounded, size: 64, color: Colors.black26),
//               const SizedBox(height: 12),
//               const Text(
//                 'Host mode is OFF',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
//               ),
//               const SizedBox(height: 8),
//               const Text(
//                 'Turn on Host Mode in Account to start listing your cars.',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.black54),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   // Navega a Account (tab 4) para activar el switch
//                   // Busca el Scaffold padre y cambia el tab mediante callback o
//                   // simplemente navega con un push a AccountView si prefieres.
//                   Navigator.of(context).push(
//                     MaterialPageRoute(builder: (_) => const AccountView()),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                 ),
//                 icon: const Icon(Icons.toggle_on),
//                 label: const Text('Go to Account'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/presentation/features/app_shell/view/app_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/repositories/users_repository.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/presentation/common_widgets/bottom_bar.dart';

import 'package:flutter_app/presentation/features/home/view/home_view.dart';
import 'package:flutter_app/presentation/features/trips/view/trips_view.dart';
import 'package:flutter_app/presentation/features/messages/view/messages_view.dart';
import 'package:flutter_app/presentation/features/settings/view/account_view.dart';
import 'package:flutter_app/presentation/features/host_home/view/host_home_view.dart';

import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';

// ⬇️ VM + repos para HostHome (MVVM)
import 'package:flutter_app/presentation/features/host_home/viewmodel/host_home_viewmodel.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';

// ⬇️ VM para Messages (MVVM)
import 'package:flutter_app/presentation/features/messages/viewmodel/messages_viewmodel.dart';

class AppShell extends StatefulWidget {
  final String currentUserId;
  final int initialIndex;

  const AppShell({
    super.key,
    required this.currentUserId,
    this.initialIndex = 0,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final isHost = context.watch<HostModeProvider>().isHostMode;

    // Tabs:
    // - Home: puedes dejar tu versión actual.
    // - Host Home: lo envolvemos con su VM.
    // - Messages: lo envolvemos con su VM.
    final tabs = <Widget>[
      // 0: Home dinámico
      isHost
          ? ChangeNotifierProvider(
              create: (_) => HostHomeViewModel(
                vehiclesRepo: context.read<VehicleRepository>(),
                currentUserId: widget.currentUserId,
              )..init(),
              child: HostHomeView(currentUserId: widget.currentUserId),
            )
          : const HomeView(),

      // 1: Trips
      const TripsView(),

      // 2: Messages
      ChangeNotifierProvider(
        create: (ctx) => MessagesViewModel(
          chat: ctx.read<ChatRepository>(), // cached
          users: ctx.read<UsersRepository>(), // or cached if you built one
          currentUserId: widget.currentUserId,
        ),
        child: MessagesView(currentUserId: widget.currentUserId),
      ),

      // 3: Account
      const AccountView(),
    ];

    // evita out-of-range si cambia la cantidad
    final safeIndex = _index.clamp(0, tabs.length - 1);

    return Scaffold(
      extendBody: true, // necesario para el efecto glass
      body: Stack(
        children: [
          // Contenido
          Positioned.fill(
            child: IndexedStack(index: safeIndex, children: tabs),
          ),
          // Tu Glass Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomBar(
              currentIndex: safeIndex,
              items: const [
                BottomBarItem(Icons.home_rounded, 'Home'),
                BottomBarItem(Icons.navigation_rounded, 'Trip'),
                BottomBarItem(Icons.chat_bubble_rounded, 'Messages'),
                BottomBarItem(Icons.person_rounded, 'Account'),
              ],
              onTap: (i) => setState(() => _index = i),
            ),
          ),
        ],
      ),
    );
  }
}
