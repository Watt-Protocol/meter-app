import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/supabase_config.dart';
import 'core/services/notification_service.dart';
import 'data/providers/auth_providers.dart';
import 'data/repositories/auth_repository.dart';
import 'app.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

late final AuthRepository appAuthRepository;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A0A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  appAuthRepository = AuthRepository(Supabase.instance.client);
  await appAuthRepository.restoreSession();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('[main] Firebase initialization failed: $e');
  }

  await NotificationService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(appAuthRepository),
      ],
      child: const WattApp(),
    ),
  );
}
