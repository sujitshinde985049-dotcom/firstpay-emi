import 'package:firstpay/app/app.dart';
import 'package:firstpay/core/config/app_config.dart';
import 'package:firstpay/services/supabase/supabase_initializer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  const config = AppConfig.fromEnvironment();
  await SupabaseInitializer.initialize(config);
  runApp(const ProviderScope(child: FirstPayApp()));
}
