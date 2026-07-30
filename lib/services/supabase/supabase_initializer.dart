import 'package:firstpay/core/config/app_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract final class SupabaseInitializer {
  static Future<void> initialize(AppConfig config) async {
    if (!config.isSupabaseConfigured) return;
    await Supabase.initialize(
      url: config.supabaseUrl,
      publishableKey: config.supabaseAnonKey,
    );
  }
}
