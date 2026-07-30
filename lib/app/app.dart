import 'package:firstpay/app/router/app_router.dart';
import 'package:firstpay/app/theme/firstpay_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FirstPayApp extends ConsumerWidget {
  const FirstPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'FirstPay',
      debugShowCheckedModeBanner: false,
      theme: FirstPayTheme.light,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
