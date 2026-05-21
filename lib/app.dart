import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/light_blue_theme.dart';
import 'core/router/app_router.dart';

class SuperStarApp extends ConsumerWidget {
  const SuperStarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'SuperStar App',
      debugShowCheckedModeBanner: false,
      theme: LightBlueTheme.theme,
      routerConfig: router,
    );
  }
}
