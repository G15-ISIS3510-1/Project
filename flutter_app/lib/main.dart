// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'presentation/features/auth/view/login_view.dart';
// import 'presentation/features/app_shell/viewmodel/host_mode_provider.dart';
// import 'data/sources/remote/user_remote_source.dart';

// // 👇 Tema auto por hora (auto/claro/oscuro)
// import 'app/theme/theme_controller.dart';

// class AuthProvider with ChangeNotifier {
//   String? _userId;
//   String? _token;
//   String? get userId => _userId;
//   String? get token => _token;

//   void signIn({required String userId, required String token}) {
//     _userId = userId;
//     _token = token;
//     notifyListeners();
//   }

//   void signOut() {
//     _userId = null;
//     _token = null;
//     notifyListeners();
//   }
// }

// const String kApiBase = String.fromEnvironment(
//   'API_BASE',
//   defaultValue: 'http://10.0.2.2:8000',
// );
// const String kApiBaseWithPrefix = '$kApiBase/api';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthProvider()),
//         ChangeNotifierProvider(create: (_) => HostModeProvider()),
//         ProxyProvider<AuthProvider, UsersApi?>(
//           update: (_, auth, __) {
//             final token = auth.token;
//             if (token == null) return null;
//             return UsersApi(baseUrl: kApiBaseWithPrefix, token: token);
//           },
//         ),
//         // 👇 Controlador de tema (Auto/Claro/Oscuro + ventana noche)
//         ChangeNotifierProvider(create: (_) => ThemeController()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // ========================
//   //   PALETA Y TIPOGRAFÍA
//   // ========================
//   static const seed = Color(0xFF4F46E5); // Indigo-ish (marca)
//   static const lightBg = Color(0xFFF7F7F7);
//   static const darkBg = Color(0xFF0F1115); // fondo “true black-ish”

//   // Texto base con Poppins
//   TextTheme _textBase(Brightness b) {
//     final isDark = b == Brightness.dark;
//     final onBg = isDark ? Colors.white : Colors.black;
//     return TextTheme(
//       displayLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
//       displayMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
//       displaySmall: TextStyle(fontFamily: 'Poppins', color: onBg),
//       headlineLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
//       headlineMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
//       headlineSmall: TextStyle(fontFamily: 'Poppins', color: onBg),
//       titleLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
//       titleMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
//       titleSmall: TextStyle(fontFamily: 'Poppins', color: onBg),
//       bodyLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
//       bodyMedium: TextStyle(
//         fontFamily: 'Poppins',
//         color: onBg.withOpacity(0.85),
//       ),
//       bodySmall: TextStyle(
//         fontFamily: 'Poppins',
//         color: onBg.withOpacity(0.70),
//       ),
//       labelLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
//       labelMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
//       labelSmall: TextStyle(fontFamily: 'Poppins', color: onBg),
//     );
//   }

//   // ========================
//   //        THEME LIGHT
//   // ========================
//   ThemeData _light() {
//     final scheme = ColorScheme.fromSeed(
//       seedColor: seed,
//       brightness: Brightness.light,
//       background: lightBg,
//       surface: Colors.white,
//     );
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.light,
//       colorScheme: scheme,
//       scaffoldBackgroundColor: lightBg,
//       textTheme: _textBase(Brightness.light),
//       appBarTheme: AppBarTheme(
//         backgroundColor: scheme.surface,
//         foregroundColor: scheme.onSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: const TextStyle(
//           fontFamily: 'Poppins',
//           fontWeight: FontWeight.w600,
//           fontSize: 18,
//         ).copyWith(color: scheme.onSurface),
//       ),
//       cardTheme: CardThemeData(
//         color: scheme.surface,
//         elevation: 0,
//         margin: const EdgeInsets.all(8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: scheme.surface,
//         selectedItemColor: scheme.primary,
//         unselectedItemColor: scheme.onSurfaceVariant,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: scheme.surface,
//         hintStyle: TextStyle(color: scheme.onSurfaceVariant),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: scheme.outlineVariant),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: scheme.outlineVariant),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: scheme.primary, width: 1.4),
//         ),
//       ),
//       chipTheme: ChipThemeData(
//         backgroundColor: scheme.surfaceVariant,
//         selectedColor: scheme.primaryContainer,
//         labelStyle: TextStyle(color: scheme.onSurface),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       ),
//       segmentedButtonTheme: SegmentedButtonThemeData(
//         style: ButtonStyle(
//           shape: WidgetStateProperty.all(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           ),
//         ),
//       ),
//       iconTheme: IconThemeData(color: scheme.onSurface),
//       snackBarTheme: SnackBarThemeData(
//         backgroundColor: scheme.inverseSurface,
//         contentTextStyle: TextStyle(color: scheme.onInverseSurface),
//         behavior: SnackBarBehavior.floating,
//       ),
//       dividerTheme: DividerThemeData(color: scheme.outlineVariant),
//       filledButtonTheme: FilledButtonThemeData(
//         style: ButtonStyle(
//           minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
//           shape: MaterialStatePropertyAll(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           backgroundColor: MaterialStatePropertyAll(scheme.primary),
//           foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ButtonStyle(
//           minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
//           shape: MaterialStatePropertyAll(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           backgroundColor: MaterialStatePropertyAll(scheme.primary),
//           foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
//         ),
//       ),
//     );
//   }

//   // ========================
//   //        THEME DARK
//   // ========================
//   ThemeData _dark() {
//     final scheme = ColorScheme.fromSeed(
//       seedColor: seed,
//       brightness: Brightness.dark,
//       background: darkBg,
//       surface: const Color(0xFF151922),
//     );
//     return ThemeData(
//       useMaterial3: true,
//       brightness: Brightness.dark,
//       colorScheme: scheme,
//       scaffoldBackgroundColor: darkBg,
//       textTheme: _textBase(Brightness.dark),
//       appBarTheme: AppBarTheme(
//         backgroundColor: scheme.surface,
//         foregroundColor: scheme.onSurface,
//         elevation: 0,
//         centerTitle: true,
//         titleTextStyle: const TextStyle(
//           fontFamily: 'Poppins',
//           fontWeight: FontWeight.w600,
//           fontSize: 18,
//         ).copyWith(color: scheme.onSurface),
//       ),
//       cardTheme: CardThemeData(
//         color: scheme.surface,
//         elevation: 0,
//         margin: const EdgeInsets.all(8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       ),
//       bottomNavigationBarTheme: BottomNavigationBarThemeData(
//         backgroundColor: scheme.surface,
//         selectedItemColor: scheme.primary,
//         unselectedItemColor: scheme.onSurfaceVariant,
//         type: BottomNavigationBarType.fixed,
//         elevation: 8,
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: const Color(0xFF1C2230),
//         hintStyle: TextStyle(color: scheme.onSurfaceVariant),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 12,
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: scheme.outlineVariant),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: scheme.outlineVariant),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: scheme.primary, width: 1.4),
//         ),
//       ),
//       chipTheme: ChipThemeData(
//         backgroundColor: const Color(0xFF1E2634),
//         selectedColor: scheme.primaryContainer,
//         labelStyle: TextStyle(color: scheme.onSurface),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
//       ),
//       segmentedButtonTheme: SegmentedButtonThemeData(
//         style: ButtonStyle(
//           shape: WidgetStateProperty.all(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           ),
//         ),
//       ),
//       iconTheme: IconThemeData(color: scheme.onSurface),
//       snackBarTheme: SnackBarThemeData(
//         backgroundColor: scheme.inverseSurface,
//         contentTextStyle: TextStyle(color: scheme.onInverseSurface),
//         behavior: SnackBarBehavior.floating,
//       ),
//       dividerTheme: DividerThemeData(color: scheme.outlineVariant),
//       filledButtonTheme: FilledButtonThemeData(
//         style: ButtonStyle(
//           minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
//           shape: MaterialStatePropertyAll(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           backgroundColor: MaterialStatePropertyAll(scheme.primary),
//           foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
//         ),
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ButtonStyle(
//           minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
//           shape: MaterialStatePropertyAll(
//             RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           ),
//           backgroundColor: MaterialStatePropertyAll(scheme.primary),
//           foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final themeCtrl = context.watch<ThemeController>();

//     return MaterialApp(
//       title: 'QOVO',
//       debugShowCheckedModeBanner: false,
//       theme: _light(),
//       darkTheme: _dark(),
//       themeMode: themeCtrl.currentMode, // ← Auto por hora / Claro / Oscuro
//       home: const SplashScreen(),
//     );
//   }
// }

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({super.key});
//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     Future.delayed(const Duration(seconds: 2), () {
//       Navigator.of(context).pushReplacement(
//         MaterialPageRoute(builder: (context) => const LoginScreen()),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//         child: Text(
//           'QOVO',
//           style: TextStyle(
//             fontSize: 64,
//             fontWeight: FontWeight.w600,
//             letterSpacing: -1.5,
//           ),
//         ),
//       ),
//     );
//   }
// }

// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/repositories/pricing_repository.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/auth_remote_source.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';
import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart';
import 'package:flutter_app/data/sources/remote/user_remote_source.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter_app/presentation/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_app/presentation/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_app/presentation/features/host_home/viewmodel/host_home_viewmodel.dart';
import 'package:flutter_app/presentation/features/vehicle/viewmodel/add_vehicle_viewmodel.dart';
import 'package:provider/provider.dart';

import 'presentation/features/auth/view/login_view.dart';
import 'presentation/features/app_shell/viewmodel/host_mode_provider.dart';

// 👇 Tema auto por hora (auto/claro/oscuro)
import 'app/theme/theme_controller.dart';

// (Opcional) si quieres fijar base al arrancar, descomenta:
// import 'data/sources/remote/api_client.dart'; // Api.I()

class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _token;
  String? get userId => _userId;
  String? get token => _token;

  void signIn({required String userId, required String token}) {
    _userId = userId;
    _token = token;
    notifyListeners();
  }

  void signOut() {
    _userId = null;
    _token = null;
    notifyListeners();
  }
}

const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'http://10.0.2.2:8000',
);
const String kApiBaseWithPrefix = kApiBase;

void main() {
  final api = Api.I();
  api.setBase(kApiBase);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HostModeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),

        Provider<Api>.value(value: api),
        Provider<VehicleService>(create: (_) => VehicleService()),
        Provider<PricingService>(create: (_) => PricingService()),
        Provider<ChatService>(create: (_) => ChatService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<AuthService>(
          create: (_) => AuthService(baseUrl: kApiBaseWithPrefix),
        ),

        Provider<VehicleRepository>(
          create: (ctx) =>
              VehicleRepositoryImpl(remote: ctx.read<VehicleService>()),
        ),

        Provider<ChatRepository>(
          create: (ctx) => ChatRepositoryImpl(remote: ctx.read<ChatService>()),
        ),
        Provider<AuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            remote: ctx.read<AuthService>(), // <- aquí va AuthService, no Api
            // storage: ... (si tu impl lo acepta opcionalmente)
          ),
        ),
        Provider<PricingRepository>(
          create: (ctx) =>
              PricingRepositoryImpl(remote: ctx.read<PricingService>()),
        ),

        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) => AuthViewModel(
            ctx.read<AuthRepository>(),
            // Evitas undefined usando el base de Api:
            baseUrl: ctx.read<Api>().baseUrl + '/api',
          ),
        ),

        ChangeNotifierProvider<HomeViewModel>(
          create: (ctx) => HomeViewModel(
            vehicles: ctx.read<VehicleRepository>(), // <- nombre correcto
            pricing: ctx.read<PricingService>(), // <- nombre correcto
          ),
        ),

        ChangeNotifierProvider<HostHomeViewModel>(
          create: (ctx) => HostHomeViewModel(
            vehiclesRepo: ctx.read<VehicleRepository>(),
            pricing: ctx.read<PricingService>(),
            currentUserId: ctx.read<AuthProvider>().userId ?? '',
          ),
        ),

        ChangeNotifierProvider(
          create: (ctx) => AddVehicleViewModel(
            vehicles: ctx.read<VehicleRepository>(),
            pricing: ctx.read<PricingRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ========================
  //   PALETA Y TIPOGRAFÍA
  // ========================
  static const seed = Color(0xFF4F46E5); // Indigo-ish (marca)
  static const lightBg = Color(0xFFF7F7F7);
  static const darkBg = Color(0xFF0F1115); // fondo “true black-ish”

  TextTheme _textBase(Brightness b) {
    final isDark = b == Brightness.dark;
    final onBg = isDark ? Colors.white : Colors.black;
    return TextTheme(
      displayLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
      displayMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
      displaySmall: TextStyle(fontFamily: 'Poppins', color: onBg),
      headlineLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
      headlineMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
      headlineSmall: TextStyle(fontFamily: 'Poppins', color: onBg),
      titleLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
      titleMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
      titleSmall: TextStyle(fontFamily: 'Poppins', color: onBg),
      bodyLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
      bodyMedium: TextStyle(
        fontFamily: 'Poppins',
        color: onBg.withOpacity(0.85),
      ),
      bodySmall: TextStyle(
        fontFamily: 'Poppins',
        color: onBg.withOpacity(0.70),
      ),
      labelLarge: TextStyle(fontFamily: 'Poppins', color: onBg),
      labelMedium: TextStyle(fontFamily: 'Poppins', color: onBg),
      labelSmall: TextStyle(fontFamily: 'Poppins', color: onBg),
    );
  }

  ThemeData _light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      background: lightBg,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: lightBg,
      textTheme: _textBase(Brightness.light),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ).copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceVariant,
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: MaterialStatePropertyAll(scheme.primary),
          foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: MaterialStatePropertyAll(scheme.primary),
          foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        ),
      ),
    );
  }

  ThemeData _dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
      background: darkBg,
      surface: const Color(0xFF151922),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: darkBg,
      textTheme: _textBase(Brightness.dark),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ).copyWith(color: scheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface,
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1C2230),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1E2634),
        selectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
      iconTheme: IconThemeData(color: scheme.onSurface),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: MaterialStatePropertyAll(scheme.primary),
          foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: MaterialStatePropertyAll(scheme.primary),
          foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeCtrl = context.watch<ThemeController>();

    return MaterialApp(
      title: 'QOVO',
      debugShowCheckedModeBanner: false,
      theme: _light(),
      darkTheme: _dark(),
      themeMode: themeCtrl.currentMode, // ← Auto por hora / Claro / Oscuro
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'QOVO',
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w600,
            letterSpacing: -1.5,
          ),
        ),
      ),
    );
  }
}
