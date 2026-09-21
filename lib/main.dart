import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/map/map_runtime.dart';
import 'core/router/app_router.dart';
import 'core/theme/rider_colors.dart';
import 'core/theme/rider_theme.dart';
import 'widgets/offline_barrier.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await warmGoogleMaps();
  runApp(const ProviderScope(child: BtsRiderApp()));
}

class BtsRiderApp extends ConsumerWidget {
  const BtsRiderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BTS Rider',
      debugShowCheckedModeBanner: false,
      theme: RiderTheme.material(),
      color: RiderColors.primary,
      routerConfig: router,
      builder: (context, child) {
        SystemChrome.setSystemUIOverlayStyle(
          const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.light,
          ),
        );
        return OfflineBarrier(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
