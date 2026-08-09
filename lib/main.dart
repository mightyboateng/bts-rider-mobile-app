import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/layout/app_shell.dart';
import 'core/state/rider_session_controller.dart';
import 'core/theme/rider_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  runApp(const BtsRiderApp());
}

class BtsRiderApp extends StatefulWidget {
  const BtsRiderApp({super.key});

  @override
  State<BtsRiderApp> createState() => _BtsRiderAppState();
}

class _BtsRiderAppState extends State<BtsRiderApp> {
  late final RiderSessionController _session;

  @override
  void initState() {
    super.initState();
    _session = RiderSessionController();
  }

  @override
  void dispose() {
    _session.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdaptiveApp(
      title: 'BTS Rider',
      themeMode: ThemeMode.light,
      materialLightTheme: RiderTheme.material(),
      materialDarkTheme: RiderTheme.material(),
      cupertinoLightTheme: RiderTheme.cupertino(),
      cupertinoDarkTheme: RiderTheme.cupertino(),
      home: AppShell(session: _session),
    );
  }
}