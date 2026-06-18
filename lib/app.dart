import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/bns_music_theme.dart';
import 'core/router/app_router.dart';
import 'presentation/providers/theme_mode_provider.dart';

class SuperStarApp extends ConsumerWidget {
  const SuperStarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'SuperStar App',
      debugShowCheckedModeBanner: false,
      theme: BnsMusicTheme.light,
      darkTheme: BnsMusicTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
