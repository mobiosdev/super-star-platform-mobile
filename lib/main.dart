import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/config/env_config.dart';
import 'core/storage/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint('SuperStar API base URL: ${EnvConfig.apiBaseUrl}');
    debugPrint('Login URL: ${EnvConfig.fullUrl('/auth/login')}');
  }
  await LocalStorage.instance.init();
  runApp(
    const ProviderScope(
      child: SuperStarApp(),
    ),
  );
}
