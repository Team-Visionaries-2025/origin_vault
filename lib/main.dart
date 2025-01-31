import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:origin_vault/core/theme/theme.dart';
import 'package:origin_vault/core/widgets/nav_bar.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: '.sup.env');

  try {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? '',
      anonKey: dotenv.env['SUPABASE_KEY'] ?? '',
      debug: true,
    );
    debugPrint("✅ Supabase initialized successfully");
  } catch (e) {
    debugPrint("❌ Error initializing Supabase: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 844),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Origin Vault',
          theme: Apptheme.themeMode,
          home: const UserPageWrapper(userLevel: 2), // Ensures Admin Navigation
        );
      },
    );
  }
}
