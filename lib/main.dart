import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:origin_vault/core/common/common_pages/homepage.dart';
import 'package:origin_vault/core/theme/theme.dart';
import 'package:origin_vault/screens/admin_level/presentation/pages/admin_dashboard.dart';
import 'package:origin_vault/screens/consumer_level/presentation/pages/consumer_dashboard.dart';
import 'package:origin_vault/screens/producer_level/presentation/pages/producer_dashboard.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.sup.env');

  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
      debug: true,
    );
  } catch (e) {
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final supabase = Supabase.instance.client;
  late StreamSubscription<AuthState> _authStateSubscription;
  bool _isLoading = true;
  Widget? _initialRoute;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
    _checkSession();
  }

  void _setupAuthListener() {
    _authStateSubscription =
        supabase.auth.onAuthStateChange.listen((data) async {
      final Session? session = data.session;
      if (session == null) {
        if (mounted) {
          setState(() {
            _initialRoute = const HomePage();
          });
        }
      } else {
        await _redirectedBasedOnRole(session.user.id);
      }
    });
  }

  Future<void> _redirectedBasedOnRole(String userId) async {
    try {
      final userData = await supabase
          .from('user_table')
          .select('role')
          .eq('user_id', userId)
          .single();

      if (mounted) {
        setState(() {
          switch (userData['role'].toString().toLowerCase()) {
            case 'producer':
              _initialRoute = const Producerdashboard();
              break;
            case 'consumer':
              _initialRoute = const Consumerdashboard();
              break;
            case 'admin':
              _initialRoute = const DashboardScreen();
              break;
            default:
              _initialRoute = const HomePage();
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialRoute = const HomePage();
        });
      }
    }
  }

  Future<void> _checkSession() async {
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        await _redirectedBasedOnRole(session.user.id);
      } else {
        if (mounted) {
          setState(() {
            _initialRoute = const HomePage();
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _initialRoute = const HomePage();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 844),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Origin Vault',
        theme: Apptheme.themeMode,
        home: _isLoading
            ? const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : _initialRoute ?? const HomePage(),
      ),
    );
  }
}
