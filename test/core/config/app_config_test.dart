import 'package:firstpay/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reports complete Supabase configuration', () {
    const config = AppConfig(
      supabaseUrl: 'https://example.supabase.co',
      publishableKey: 'demo-anon-key',
    );
    expect(config.isSupabaseConfigured, isTrue);
  });

  test('rejects incomplete Supabase configuration', () {
    const config = AppConfig(supabaseUrl: '', publishableKey: '');
    expect(config.isSupabaseConfigured, isFalse);
  });
}
