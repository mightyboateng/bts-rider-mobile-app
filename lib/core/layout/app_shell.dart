import 'package:flutter/material.dart';

import '../../features/home/home_shell.dart';

/// Kept so older imports still compile. The live shell is [HomeShell].
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) => const HomeShell();
}
