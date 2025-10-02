// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'LoginRegister/login.dart';
import 'host_mode_provider.dart';
import 'data/users_api.dart';

// 👇 AuthProvider súper simple (ponlo en su archivo si ya tienes uno)
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
const String kApiBaseWithPrefix = '$kApiBase/api';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => HostModeProvider()),

        // ✅ UsersApi depende del token de AuthProvider
        ProxyProvider<AuthProvider, UsersApi?>(
          update: (_, auth, previous) {
            final token = auth.token;
            if (token == null) return null;
            return UsersApi(baseUrl: 'http://10.0.2.2:8000/api', token: token);
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Qovo Login',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 247, 247, 247),
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
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
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
