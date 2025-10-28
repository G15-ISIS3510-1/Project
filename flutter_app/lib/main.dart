import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart'; // for WidgetsFlutterBinding (Material also exports it, but it's fine)
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/auth_remote_source.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';
import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart';
import 'package:flutter_app/data/sources/remote/user_remote_source.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter_app/data/sources/remote/analytics_remote_source.dart';

import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/repositories/pricing_repository.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_app/data/repositories/analytics_repository.dart';

import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';
import 'package:flutter_app/presentation/features/auth/view/login_view.dart';
import 'package:flutter_app/presentation/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_app/presentation/features/booking/viewmodel/booking_viewmodel.dart';
import 'package:flutter_app/presentation/features/booking_reminders/viewmodel/booking_reminder_viewmodel.dart';
import 'package:flutter_app/presentation/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_app/presentation/features/host_home/viewmodel/host_home_viewmodel.dart';
import 'package:flutter_app/presentation/features/profile/viewmodel/visited_places_viewmodel.dart';
import 'package:flutter_app/presentation/features/trips/viewmodel/trips_viewmodel.dart';
import 'package:flutter_app/presentation/features/vehicle/viewmodel/add_vehicle_viewmodel.dart';

import 'app/theme/theme_controller.dart';

/// Lightweight auth/session holder the UI can read.
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

/// Base URL the app talks to (points to your deployed FastAPI)
const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://qovo-api-862569067561.us-central1.run.app',
);

// If your AuthService expects just the base, keep it the same
const String kApiBaseWithPrefix = kApiBase;

/// MAIN 🌟
/// - ensures bindings
/// - loads intl date symbols (fixes TripsViewModel date formatting crash)
/// - sets Api base
/// - builds providers
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⬅ THIS fixes the "LocaleDataException: call initializeDateFormatting"
  await initializeDateFormatting();

  // init singletons / services
  final api = Api.I();
  api.setBase(kApiBase);

  final httpClient = http.Client();

  runApp(
    MultiProvider(
      providers: [
        // session + app mode
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HostModeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),

        // low-level services / sources
        Provider<Api>.value(value: api),
        Provider<http.Client>.value(value: httpClient),

        Provider<VehicleService>(create: (_) => VehicleService()),
        Provider<PricingService>(create: (_) => PricingService()),
        Provider<ChatService>(create: (_) => ChatService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<BookingService>(create: (_) => BookingService()),
        Provider<AuthService>(
          create: (_) => AuthService(baseUrl: kApiBaseWithPrefix),
        ),

        Provider<AnalyticsRemoteSource>(
          create: (ctx) => AnalyticsRemoteSourceImpl(
            client: ctx.read<http.Client>(),
            baseUrl: kApiBase,
          ),
        ),

        // repositories
        Provider<BookingsRepository>(
          create: (ctx) => BookingsRepositoryImpl(
            ctx.read<BookingService>(),
          ),
        ),
        Provider<VehicleRepository>(
          create: (ctx) => VehicleRepositoryImpl(
            remote: ctx.read<VehicleService>(),
          ),
        ),
        Provider<ChatRepository>(
          create: (ctx) => ChatRepositoryImpl(
            remote: ctx.read<ChatService>(),
          ),
        ),
        Provider<AuthRepository>(
          create: (ctx) => AuthRepositoryImpl(
            remote: ctx.read<AuthService>(),
            // if AuthRepositoryImpl also needs storage/local cache, add it here
          ),
        ),
        Provider<PricingRepository>(
          create: (ctx) => PricingRepositoryImpl(
            remote: ctx.read<PricingService>(),
          ),
        ),
        Provider<AnalyticsRepository>(
          create: (ctx) => AnalyticsRepositoryImpl(
            remoteSource: ctx.read<AnalyticsRemoteSource>(),
          ),
        ),

        // viewmodels (global / long-lived tabs)

        /// Reminders analytics VM
        ChangeNotifierProvider<BookingReminderViewModel>(
          create: (ctx) => BookingReminderViewModel(
            ctx.read<AnalyticsRepository>(),
          ),
        ),

        /// Auth flow VM
        ChangeNotifierProvider<AuthViewModel>(
          create: (ctx) => AuthViewModel(
            ctx.read<AuthRepository>(),
            baseUrl: ctx.read<Api>().baseUrl + '/api',
          ),
        ),

        /// Home tab VM (renter browse vehicles)
        ChangeNotifierProvider<HomeViewModel>(
          create: (ctx) => HomeViewModel(
            vehicles: ctx.read<VehicleRepository>(),
            pricing: ctx.read<PricingService>(),
          ),
        ),

        /// Host home tab VM (my fleet, pricing)
        ChangeNotifierProvider<HostHomeViewModel>(
          create: (ctx) => HostHomeViewModel(
            vehiclesRepo: ctx.read<VehicleRepository>(),
            pricing: ctx.read<PricingService>(),
            currentUserId: ctx.read<AuthProvider>().userId ?? '',
          ),
        ),

        /// Add-vehicle flow VM (host creates listing)
        ChangeNotifierProvider<AddVehicleViewModel>(
          create: (ctx) => AddVehicleViewModel(
            vehicles: ctx.read<VehicleRepository>(),
            pricing: ctx.read<PricingRepository>(),
          ),
        ),

        /// Places visited VM (profile -> visited places)
        ChangeNotifierProvider<VisitedPlacesViewModel>(
          create: (_) => VisitedPlacesViewModel(),
        ),

        /// Trips tab VM (bookings list)
        /// NOTE: .init() is called here so the first Trips screen render
        /// can just read data instead of kicking off work every time.
        ChangeNotifierProvider<TripsViewModel>(
          create: (ctx) =>
              TripsViewModel(
                ctx.read<BookingsRepository>(),
              )..init(),
        ),

        /// BookingViewModel used in booking details / chat-from-booking
        ChangeNotifierProvider<BookingViewModel>(
          create: (ctx) => BookingViewModel(
            bookingsRepo: ctx.read<BookingsRepository>(),
            chatRepo: ctx.read<ChatRepository>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget, wires theme + splash routing
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // ===== Brand palette / typography helpers =====

  static const seed = Color(0xFF4F46E5); // Indigo-ish brand color
  static const lightBg = Color(0xFFF7F7F7);
  static const darkBg = Color(0xFF0F1115);

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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(scheme.primary),
          foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
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
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          backgroundColor: MaterialStatePropertyAll(scheme.primary),
          foregroundColor: MaterialStatePropertyAll(scheme.onPrimary),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const MaterialStatePropertyAll(Size.fromHeight(48)),
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
      themeMode: themeCtrl.currentMode, // auto / light / dark
      home: const SplashScreen(),
      showPerformanceOverlay: true, // TEMP for perf debugging
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

    // dumb splash → login
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
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
