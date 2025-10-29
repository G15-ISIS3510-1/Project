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
import 'package:flutter_app/presentation/features/app_shell/view/app_shell.dart';
import 'package:flutter_app/presentation/features/auth/view/login_view.dart';
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

/// Auth/session holder leído por la UI.
class AuthProvider with ChangeNotifier {
  String? _userId;
  String? _token;
  final Future<void> Function(String oldUid)? _onSignOut;

  AuthProvider({Future<void> Function(String oldUid)? onSignOut})
    : _onSignOut = onSignOut;

  String? get userId => _userId;
  String? get token => _token;

  void signIn({required String userId, required String token}) {
    _userId = userId;
    _token = token;

    // 🔐 importantísimo: volver a setear token para próximas llamadas
    try {
      Api.I().setToken(token);
    } catch (_) {}

    notifyListeners();
  }

  Future<void> signOut() async {
    final oldUid = _userId ?? 'anon';
    if (_onSignOut != null) {
      await _onSignOut!(oldUid);
    }
    _userId = null;
    _token = null;
    notifyListeners();
  }
}

/// Base URL
const String kApiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://qovo-api-862569067561.us-central1.run.app',
);
const String kApiBaseWithPrefix = kApiBase;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  final api = Api.I();
  api.setBase(kApiBase);
  final httpClient = http.Client();

  runApp(
    MultiProvider(
      providers: [
        // ───────── session + mode + theme
        ChangeNotifierProvider(
          create: (c) =>
              AuthProvider(onSignOut: (oldUid) => _clearAppData(c, oldUid)),
        ),
        ChangeNotifierProvider(create: (_) => HostModeProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),

        // ───────── DB & DAOs (por usuario)
        ProxyProvider<AuthProvider, AppDatabase>(
          update: (c, auth, previous) {
            final uid = auth.userId ?? 'anon';
            if (previous != null &&
                previous.ownerUid == uid &&
                !previous.isClosed) {
              return previous;
            }
            return AppDatabase.forUser(uid);
          },
          dispose: (_, db) => db.close(),
        ),
        ProxyProvider<AppDatabase, InfraDao>(
          update: (c, db, _) => InfraDao(db),
        ),
        ProxyProvider<AppDatabase, VehiclesDao>(
          update: (c, db, _) => VehiclesDao(db),
        ),
        ProxyProvider<AppDatabase, VehicleAvailabilityDao>(
          update: (c, db, _) => VehicleAvailabilityDao(db),
        ),
        ProxyProvider<AppDatabase, PricingDao>(
          update: (c, db, _) => PricingDao(db),
        ),
        ProxyProvider<AppDatabase, BookingsDao>(
          update: (c, db, _) => BookingsDao(db),
        ),
        ProxyProvider<AppDatabase, ConversationsDao>(
          update: (c, db, _) => ConversationsDao(db),
        ),
        ProxyProvider<AppDatabase, MessagesDao>(
          update: (c, db, _) => MessagesDao(db),
        ),
        ProxyProvider<AppDatabase, KvDao>(update: (c, db, _) => KvDao(db)),

        // ───────── locals / prefs / stores
        ProxyProvider2<VehiclesDao, InfraDao, VehicleLocalSource>(
          update: (c, vDao, infra, _) => VehicleLocalSource(vDao, infra),
        ),
        ProxyProvider2<
          VehicleAvailabilityDao,
          InfraDao,
          AvailabilityLocalSource
        >(update: (c, aDao, infra, _) => AvailabilityLocalSource(aDao, infra)),
        ProxyProvider2<PricingDao, InfraDao, PricingLocalSource>(
          update: (c, pDao, infra, _) => PricingLocalSource(pDao, infra),
        ),
        ProxyProvider2<BookingsDao, InfraDao, BookingLocalSource>(
          update: (c, bDao, infra, _) => BookingLocalSource(bDao, infra),
        ),
        ProxyProvider2<ConversationsDao, InfraDao, ConversationLocalSource>(
          update: (c, convDao, infra, _) =>
              ConversationLocalSource(convDao, infra),
        ),
        ProxyProvider2<MessagesDao, InfraDao, MessageLocalSource>(
          update: (c, msgDao, infra, _) => MessageLocalSource(msgDao, infra),
        ),
        ProxyProvider<KvDao, DraftsStore>(
          update: (c, kv, _) => DraftsStore(kv),
        ),
        ProxyProvider<KvDao, SuggestedPriceStore>(
          update: (c, kv, _) => SuggestedPriceStore(kv),
        ),
        ProxyProvider<KvDao, BookingRemindersStore>(
          update: (c, kv, _) => BookingRemindersStore(kv),
        ),
        Provider<LastReadPrefs>(create: (_) => LastReadPrefs()),

        // ───────── low-level remote services
        Provider<Api>.value(value: api),
        Provider<http.Client>.value(value: httpClient),
        Provider<VehicleService>(create: (_) => VehicleService()),
        Provider<AvailabilityService>(create: (_) => AvailabilityService()),
        Provider<PricingService>(create: (_) => PricingService()),
        Provider<BookingService>(create: (_) => BookingService()),
        Provider<ChatService>(create: (_) => ChatService()),
        Provider<UserService>(create: (_) => UserService()),
        Provider<AuthService>(
          create: (_) => AuthService(baseUrl: kApiBaseWithPrefix),
        ),
        Provider<AnalyticsRemoteSource>(
          create: (c) => AnalyticsRemoteSourceImpl(
            client: c.read<http.Client>(),
            baseUrl: kApiBase,
          ),
        ),

        // ───────── remote repositories (impl)
        Provider<UsersRepository>(
          create: (c) => UsersRepository(remote: c.read<UserService>()),
        ),
        Provider<VehicleRepositoryImpl>(
          create: (c) =>
              VehicleRepositoryImpl(remote: c.read<VehicleService>()),
        ),
        Provider<AvailabilityRepositoryImpl>(
          create: (c) =>
              AvailabilityRepositoryImpl(remote: c.read<AvailabilityService>()),
        ),
        Provider<PricingRepositoryImpl>(
          create: (c) =>
              PricingRepositoryImpl(remote: c.read<PricingService>()),
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

        // ───────── cached repositories (atados a usuario/rol)
        ProxyProvider3<
          VehicleRepositoryImpl,
          VehiclesDao,
          InfraDao,
          VehicleRepository
        >(
          update: (c, remote, vDao, infra, _) => VehicleRepositoryCached(
            remoteRepo: remote,
            vehiclesDao: vDao,
            infraDao: infra,
          ),
        ),

        // Availability / Pricing sin cambios de identidad por usuario
        ProxyProvider2<
          AvailabilityRepositoryImpl,
          AvailabilityLocalSource,
          AvailabilityRepository
        >(
          update: (c, remote, local, _) =>
              AvailabilityRepositoryCached(remote: remote, local: local),
        ),
        ProxyProvider3<
          PricingRepositoryImpl,
          PricingLocalSource,
          SuggestedPriceStore,
          PricingRepository
        >(
          update: (c, remote, local, suggest, _) => PricingRepositoryCached(
            remote: remote,
            local: local,
            suggestStore: suggest,
            priceGetter: (sp) => sp.value,
          ),
        ),

        // ⚠️ BookingsRepository: dependemos de Auth + HostMode para filtrar por usuario/rol
        ProxyProvider4<
          BookingsRepositoryImpl, // remote impl
          BookingLocalSource, // local
          AuthProvider, // usuario actual
          HostModeProvider, // rol actual
          BookingsRepository
        >(
          update: (c, remote, local, auth, hostMode, _) =>
              BookingsRepositoryCached(
                remote: remote,
                local: local,
                currentUserId: () => auth.userId ?? '',
                isHost: () => hostMode.isHostMode,
              ),
        ),

        // ChatRepository cambia con la DB (y conoce currentUserId)
        ProxyProvider<AppDatabase, ChatRepository>(
          update: (c, db, _) => ChatRepositoryCached(
            remote: c.read<ChatRepositoryImpl>(),
            convLocal: c.read<ConversationLocalSource>(),
            msgLocal: c.read<MessageLocalSource>(),
            convDao: c.read<ConversationsDao>(),
            msgDao: c.read<MessagesDao>(),
            lastReadPrefs: c.read<LastReadPrefs>(),
            currentUserId: () => c.read<AuthProvider>().userId ?? '',
          ),
        ),

        // ───────── ViewModels
        ChangeNotifierProvider<BookingReminderViewModel>(
          create: (c) =>
              BookingReminderViewModel(c.read<AnalyticsRepository>()),
        ),
        ChangeNotifierProvider<AuthViewModel>(
          create: (c) => AuthViewModel(
            c.read<AuthRepository>(),
            baseUrl: c.read<Api>().baseUrl + '/api',
          ),
        ),

        // HomeViewModel: recreamos simple (si te vuelve a dar dispose, te paso patrón “update in-place”)
        ChangeNotifierProxyProvider<AuthProvider, HomeViewModel>(
          create: (c) => HomeViewModel(
            vehicles: c.read<VehicleRepository>(),
            pricing: c.read<PricingService>(),
          ),
          update: (c, auth, prev) => HomeViewModel(
            vehicles: c.read<VehicleRepository>(),
            pricing: c.read<PricingService>(),
          ),
        ),

        ChangeNotifierProxyProvider<AuthProvider, HostHomeViewModel>(
          create: (c) => HostHomeViewModel(
            vehiclesRepo: c.read<VehicleRepository>(),
            pricing: c.read<PricingService>(),
            currentUserId: c.read<AuthProvider>().userId ?? '',
          ),
          update: (c, auth, prev) => HostHomeViewModel(
            vehiclesRepo: c.read<VehicleRepository>(),
            pricing: c.read<PricingService>(),
            currentUserId: auth.userId ?? '',
          ),
        ),

        // Trips: instancia NUEVA por usuario para limpiar estado
        ChangeNotifierProxyProvider<AuthProvider, TripsViewModel>(
          create: (c) {
            final vm = TripsViewModel(c.read<BookingsRepository>());
            vm.init();
            return vm;
          },
          update: (c, auth, prev) {
            final vm = TripsViewModel(c.read<BookingsRepository>());
            vm.init(); // reinicia chunk/paginación
            return vm;
          },
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

        ChangeNotifierProxyProvider<AuthProvider, MessagesViewModel>(
          create: (c) => MessagesViewModel(
            chat: c.read<ChatRepository>(),
            users: c.read<UsersRepository>(),
            currentUserId: c.read<AuthProvider>().userId ?? '',
          ),
          update: (c, auth, previous) {
            final uid = auth.userId ?? '';
            if (previous == null || previous.currentUserId != uid) {
              return MessagesViewModel(
                chat: c.read<ChatRepository>(),
                users: c.read<UsersRepository>(),
                currentUserId: uid,
              );
            }
            return previous;
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// Root widget, theme + splash
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const seed = Color(0xFF4F46E5);
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
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFF1C2230),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
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
      key: ValueKey('user:' + (context.watch<AuthProvider>().userId ?? 'anon')),
      title: 'QOVO',
      debugShowCheckedModeBanner: false,
      theme: _light(),
      darkTheme: _dark(),
      themeMode: themeCtrl.currentMode,
      home: const SplashScreen(),
      showPerformanceOverlay: true, // TEMP
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
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      final uid = context.read<AuthProvider>().userId;
      if (uid == null || uid.isEmpty) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => AppShell(currentUserId: uid, initialIndex: 0),
          ),
        );
      }
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

Future<void> _clearAppData(BuildContext c, String oldUid) async {
  // corta token
  try {
    Api.I().setToken(null);
    Api.I().close();
  } catch (_) {}

  // caches en memoria
  try {
    final vRepo = c.read<VehicleRepository>();
    if (vRepo is VehicleRepositoryCached) vRepo.clearCache();
  } catch (_) {}
  try {
    final bRepo = c.read<BookingsRepository>();
    if (bRepo is BookingsRepositoryCached) bRepo.clearCache();
  } catch (_) {}
  try {
    final chRepo = c.read<ChatRepository>();
    if (chRepo is ChatRepositoryCached) chRepo.clearOnLogout();
  } catch (_) {}

  // limpia tablas del usuario saliente
  try {
    await c.read<VehiclesDao>().clearAll();
  } catch (_) {}
  try {
    await c.read<VehicleAvailabilityDao>().clearAll();
  } catch (_) {}
  try {
    await c.read<PricingDao>().clearAll();
  } catch (_) {}
  try {
    await c.read<BookingsDao>().clearAll();
  } catch (_) {}
  try {
    await c.read<ConversationsDao>().clearAll();
  } catch (_) {}
  try {
    await c.read<MessagesDao>().clearAll();
  } catch (_) {}
  try {
    await c.read<InfraDao>().clearAll();
  } catch (_) {}

  try {
    await c.read<AuthRepository>().clearToken();
  } catch (_) {}

  try {
    c.read<HostModeProvider>().setHostMode(false); // ← reset al salir
  } catch (_) {}

  // No matar isolates de Drift aquí (evita “connection was closed”)
}
