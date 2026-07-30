class AppConfig {
  const AppConfig({required this.supabaseUrl, required this.publishableKey});

  const AppConfig.fromEnvironment()
    : supabaseUrl = const String.fromEnvironment('SUPABASE_URL'),
      publishableKey = const String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  final String supabaseUrl;
  final String publishableKey;

  bool get isSupabaseConfigured =>
      Uri.tryParse(supabaseUrl)?.hasScheme == true && publishableKey.isNotEmpty;
}
