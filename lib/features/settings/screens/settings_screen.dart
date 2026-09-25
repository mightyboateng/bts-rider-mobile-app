import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/app_links.dart';
import '../../../core/utils/haptics.dart';
import '../../../data/providers/session_provider.dart';

class RiderSettingsScreen extends ConsumerWidget {
  const RiderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);
    final user = session.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(user?.displayName ?? 'Rider', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            user?.phone ?? '',
            style: theme.textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
          ),
          const SizedBox(height: 20),
          _Tile(
            icon: Icons.person_outline_rounded,
            title: 'Update profile',
            subtitle: 'Name customers see on a job',
            onTap: () => context.push('/settings/profile'),
          ),
          _Tile(
            icon: Icons.history_rounded,
            title: 'Ride history',
            subtitle: 'Trips you have taken',
            onTap: () => context.push('/rides'),
          ),
          _Tile(
            icon: Icons.star_outline_rounded,
            title: 'Rate the app',
            subtitle: 'Leave a rating on the store',
            onTap: () => AppLinks.rateApp(context),
          ),
          _Tile(
            icon: Icons.ios_share_rounded,
            title: 'Share the app',
            subtitle: 'Invite another rider',
            onTap: () => AppLinks.shareApp(context),
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: () => ref.read(sessionProvider.notifier).signOut(),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: RiderColors.primaryTint30.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: RiderColors.primary, size: 20),
      ),
      title: Text(title, style: theme.textTheme.titleMedium),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded, color: RiderColors.mutedText),
      onTap: () {
        RiderHaptics.light();
        onTap();
      },
    );
  }
}
