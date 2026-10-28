import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/supabase_constants.dart';
import 'core/services/brew_points_service.dart';
import 'core/services/brew_timer_service.dart';
import 'core/services/favorite_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
  } catch (error) {
    debugPrint('dotenv load skipped or failed: $error');
  }

  try {
    await Supabase.initialize(
      url: SupabaseConstants.supabaseUrl,
      publishableKey: SupabaseConstants.supabaseAnonKey,
    );
  } catch (error) {
    debugPrint('Supabase init error: $error');
  }

  try {
    await NotificationService.instance.initialize();
  } catch (error) {
    debugPrint('NotificationService init error: $error');
  }

  try {
    await BrewTimerService.instance.initialize();
  } catch (error) {
    debugPrint('BrewTimerService init error: $error');
  }

  try {
    await BrewPointsService.instance.ensureLoaded();
  } catch (error) {
    debugPrint('BrewPointsService init error: $error');
  }

  try {
    await FavoriteService.instance.ensureLoaded();
  } catch (error) {
    debugPrint('FavoriteService init error: $error');
  }

  runApp(const BrewMasterHubApp());
}

class BrewMasterHubApp extends StatelessWidget {
  const BrewMasterHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BrewMaster Hub',
      theme: AppTheme.theme,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      home: const SplashScreen(),
    );
  }
}
