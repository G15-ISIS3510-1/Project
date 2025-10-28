// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/widgets.dart'; // WidgetsFlutterBinding
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

// ===== Local DB / DAOs / Local Sources / Stores =====
import 'package:flutter_app/data/database/app_database.dart';
import 'package:flutter_app/data/database/daos/bookings_dao.dart';
import 'package:flutter_app/data/database/daos/conversations_dao.dart';
import 'package:flutter_app/data/database/daos/infra_dao.dart';
import 'package:flutter_app/data/database/daos/kv_dao.dart';
import 'package:flutter_app/data/database/daos/messages_dao.dart';
import 'package:flutter_app/data/database/daos/pricing_dao.dart';
import 'package:flutter_app/data/database/daos/vehicle_availability_dao.dart';
import 'package:flutter_app/data/database/daos/vehicles_dao.dart';

import 'package:flutter_app/data/prefs/last_read_prefs.dart';

import 'package:flutter_app/data/sources/local/availability_local_source.dart';
import 'package:flutter_app/data/sources/local/booking_local_source.dart';
import 'package:flutter_app/data/sources/local/conversation_local_source.dart';
import 'package:flutter_app/data/sources/local/message_local_source.dart';
import 'package:flutter_app/data/sources/local/pricing_local_source.dart';
import 'package:flutter_app/data/sources/local/vehicle_local_source.dart';

import 'package:flutter_app/data/stores/booking_reminders_store.dart';
import 'package:flutter_app/data/stores/drafts_store.dart';
import 'package:flutter_app/data/stores/suggested_price_store.dart';

// ===== Remote / API =====
import 'package:flutter_app/data/sources/remote/api_client.dart';
import 'package:flutter_app/data/sources/remote/auth_remote_source.dart';
import 'package:flutter_app/data/sources/remote/availability_remote_source.dart';
import 'package:flutter_app/data/sources/remote/booking_remote_source.dart';
import 'package:flutter_app/data/sources/remote/chat_remote_source.dart';
import 'package:flutter_app/data/sources/remote/pricing_remote_source.dart';
import 'package:flutter_app/data/sources/remote/user_remote_source.dart';
import 'package:flutter_app/data/sources/remote/vehicle_remote_source.dart';
import 'package:flutter_app/data/sources/remote/analytics_remote_source.dart';

// ===== Repositories (impl + cached) =====
import 'package:flutter_app/data/repositories/auth_repository.dart';
import 'package:flutter_app/data/repositories/booking_repository.dart';
import 'package:flutter_app/data/repositories/vehicle_repository.dart';
import 'package:flutter_app/data/repositories/availability_repository.dart';
import 'package:flutter_app/data/repositories/pricing_repository.dart';
import 'package:flutter_app/data/repositories/chat_repository.dart';
import 'package:flutter_app/data/repositories/users_repository.dart';
import 'package:flutter_app/data/repositories/analytics_repository.dart';

import 'package:flutter_app/data/repositories/vehicle_repository_cached.dart';
import 'package:flutter_app/data/repositories/availability_repository_cached.dart';
import 'package:flutter_app/data/repositories/booking_repository_cached.dart';
import 'package:flutter_app/data/repositories/pricing_repository_cached.dart';
import 'package:flutter_app/data/repositories/chat_repository_cached.dart';

// ===== UI / ViewModels =====
import 'package:flutter_app/presentation/features/app_shell/viewmodel/host_mode_provider.dart';
import 'package:flutter_app/presentation/features/auth/view/login_view.dart';
import 'package:flutter_app/presentation/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:flutter_app/presentation/features/booking/viewmodel/booking_viewmodel.dart';
import 'package:flutter_app/presentation/features/booking_reminders/viewmodel/booking_reminder_viewmodel.dart';
import 'package:flutter_app/presentation/features/home/viewmodel/home_viewmodel.dart';
import 'package:flutter_app/presentation/features/host_home/viewmodel/host_home_viewmodel.dart';
import 'package:flutter_app/presentation/features/messages/viewmodel/messages_viewmodel.dart';
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
const String kApiBaseWithPrefix = kApiBase;

/// MAIN
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fixes TripsViewModel date formatting (and any intl usage)
  await initializeDateFormatting();

  // Init singletons / services
  final api = Api.I();
  api.setBase(kApiBase);
  final httpClient = http.Client();

  runApp(
    MultiProvider(
      providers: [
        // ─────────────────────────
        // session + app mode + theme
        // ─────────────────────────
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HostModeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),

        // ─────────────────────────
        // Database & DAOs
        // ─────────────────────────
        Provider<AppDatabase>(create: (_) => AppDatabase()),
        Provider<InfraDao>(create: (c) => InfraDao(c.read<AppDatabase>())),
        Provider<VehiclesDao>(create: (c) => VehiclesDao(c.read<AppDatabase>())),
        Provider<VehicleAvailabilityDao>(
            create: (c) => VehicleAvailabilityDao(c.read<AppDatabase>())),
        Provider<PricingDao>(create: (c) => PricingDao(c.read<AppDatabase>())),
        Provider<BookingsDao>(create: (c) => BookingsDao(c.read<AppDatabase>())),
        Provider<ConversationsDao>(
            create: (c) => ConversationsDao(c.read<AppDatabase>())),
        Provider<MessagesDao>(create: (c) => MessagesDao(c.read<AppDatabase>())),
        Provider<KvDao>(create: (c) => KvDao(c.read<AppDatabase>())),

        // ─────────────────────────
        // Local sources / prefs / stores
        // ─────────────────────────
        Provider<VehicleLocalSource>(
          create: (c) => VehicleLocalSource(
            c.read<VehiclesDao>(),
            c.read<InfraDao>(),
          ),
        ),
        Provider<AvailabilityLocalSource>(
          create: (c) => AvailabilityLocalSource(
            c.read<VehicleAvailabilityDao>(),
            c.read<InfraDao>(),
          ),
        ),
        Provider<PricingLocalSource>(
          create: (c) => PricingLocalSource(
            c.read<PricingDao>(),
            c.read<InfraDao>(),
          ),
        ),
        Provider<BookingLocalSource>(
          create: (c) => BookingLocalSource(
            c.read<BookingsDao>(),
            c.read<InfraDao>(),
          ),
        ),
        Provider<ConversationLocalSource>(
          create: (c) => ConversationLocalSource(
            c.read<ConversationsDao>(),
            c.read<InfraDao>(),
          ),
        ),
        Provider<MessageLocalSource>(
          create: (c) => MessageLocalSource(
            c.read<MessagesDao>(),
            c.read<InfraDao>(),
          ),
        ),
        Provider<DraftsStore>(create: (c) => DraftsStore(c.read<KvDao>())),
        Provider<SuggestedPriceStore>(
          create: (c) => SuggestedPriceStore(c.read<KvDao>()),
        ),
        Provider<BookingRemindersStore>(
          create: (c) => BookingRemindersStore(c.read<KvDao>()),
        ),
        Provider<LastReadPrefs>(create: (_) => LastReadPrefs()),

        // ─────────────────────────
        // Low-level remote services (1 instance app-wide)
        // ─────────────────────────
        Provider<Api>.value(value: api),
        Provider<http.Client>.value(value: httpClient),

        Provider<VehicleService>(create: (_) => VehicleService()),
        Provider<AvailabilityService>(create: (_) => AvailabilityService()),
        Provider<PricingService>(create: (_) => PricingService()),
        Provider<BookingService>(create: (_) => BookingService()),
        Provider<ChatService>(create: (_) => ChatService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<AuthService>(create: (_) => AuthService(baseUrl: kApiBaseWithPrefix)),
        Provider<AnalyticsRemoteSource>(
          create: (c) => AnalyticsRemoteSourceImpl(
            client: c.read<http.Client>(),
            baseUrl: kApiBase,
          ),
        ),

        // ─────────────────────────
        // Remote repositories (Impl)
        // ─────────────────────────
        Provider<UsersRepository>(
          create: (c) => UsersRepository(remote: c.read<UserService>()),
        ),
        Provider<VehicleRepositoryImpl>(
          create: (c) => VehicleRepositoryImpl(remote: c.read<VehicleService>()),
        ),
        Provider<AvailabilityRepositoryImpl>(
          create: (c) => AvailabilityRepositoryImpl(remote: c.read<AvailabilityService>()),
        ),
        Provider<PricingRepositoryImpl>(
          create: (c) => PricingRepositoryImpl(remote: c.read<PricingService>()),
        ),
        Provider<BookingsRepositoryImpl>(
          create: (c) => BookingsRepositoryImpl(c.read<BookingService>()),
        ),
        Provider<ChatRepositoryImpl>(
          create: (c) => ChatRepositoryImpl(remote: c.read<ChatService>()),
        ),
        Provider<AuthRepository>(
          create: (c) => AuthRepositoryImpl(remote: c.read<AuthService>()),
        ),
        Provider<AnalyticsRepository>(
          create: (c) => AnalyticsRepositoryImpl(
            remoteSource: c.read<AnalyticsRemoteSource>(),
          ),
        ),

        // ─────────────────────────
        // Cached repositories (wrap Impl + local)
        // ─────────────────────────
        Provider<VehicleRepository>(
          create: (c) => VehicleRepositoryCached(
            remoteRepo: c.read<VehicleRepositoryImpl>(),
            vehiclesDao: c.read<VehiclesDao>(),
            infraDao: c.read<InfraDao>(),
          ),
        ),
        Provider<AvailabilityRepository>(
          create: (c) => AvailabilityRepositoryCached(
            remoteRepo: c.read<AvailabilityRepositoryImpl>(),
            local: c.read<AvailabilityLocalSource>(),
          ),
        ),
        Provider<PricingRepository>(
          create: (c) => PricingRepositoryCached(
            remote: c.read<PricingRepositoryImpl>(),
            local: c.read<PricingLocalSource>(),
            suggestStore: c.read<SuggestedPriceStore>(),
            priceGetter: (sp) => sp.value,
          ),
        ),
        Provider<BookingsRepository>(
          create: (c) => BookingsRepositoryCached(
            remote: c.read<BookingsRepositoryImpl>(),
            local: c.read<BookingLocalSource>(),
          ),
        ),
        Provider<ChatRepository>(
          create: (c) => ChatRepositoryCached(
            remote: c.read<ChatRepositoryImpl>(),
            convLocal: c.read<ConversationLocalSource>(),
            msgLocal: c.read<MessageLocalSource>(),
            convDao: c.read<ConversationsDao>(),
            msgDao: c.read<MessagesDao>(),
            lastReadPrefs: c.read<LastReadPrefs>(),
            currentUserId: () => c.read<AuthProvider>().userId ?? '',
          ),
        ),

        // ─────────────────────────
        // ViewModels
        // ─────────────────────────
        ChangeNotifierProvider<BookingReminderViewModel>(
          create: (c) => BookingReminderViewModel(c.read<AnalyticsRepository>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (c) => AuthViewModel(
            c.read<AuthRepository>(),
            baseUrl: c.read<Api>().baseUrl + '/api',
          ),
        ),
        ChangeNotifierProvider<HomeViewModel>(
          create: (c) => HomeViewModel(
            vehicles: c.read<VehicleRepository>(),
            pricing: c.read<PricingService>(), // HomeVM usa service
          ),
        ),
        ChangeNotifierProvider<HostHomeViewModel>(
          create: (c) => HostHomeViewModel(
            vehiclesRepo: c.read<VehicleRepository>(),
            pricing: c.read<PricingService>(),
            currentUserId: c.read<AuthProvider>().userId ?? '',
          ),
        ),
        ChangeNotifierProvider<TripsViewModel>(
          create: (c) => TripsViewModel(c.read<BookingsRepository>())..init(),
        ),
        ChangeNotifierProvider<BookingViewModel>(
          create: (c) => BookingViewModel(
            bookingsRepo: c.read<BookingsRepository>(),
            chatRepo: c.read<ChatRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (c) => AddVehicleViewModel(
            vehicles: c.read<VehicleRepository>(),
            pricing: c.read<PricingRepository>(),
          ),
        ),
        ChangeNotifierProvider<VisitedPlacesViewModel>(
          create: (_) => VisitedPlacesViewModel(),
        ),
        ChangeNotifierProvider<MessagesViewModel>(
          create: (c) => MessagesViewModel(
            chat: c.read<ChatRepository>(),
            users: c.read<UsersRepository>(),
            currentUserId: c.read<AuthProvider>().userId ?? '',
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
      bodyMedium: TextStyle(fontFamily: 'Poppins', color: onBg.withOpacity(0.85)),
      bodySmall: TextStyle(fontFamily: 'Poppins', color: onBg.withOpacity(0.70)),
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
      cardTheme: const CardTheme().copyWith(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
      cardTheme: const CardTheme().copyWith(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
    // Simple splash → login
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
