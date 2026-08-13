import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen> {
  bool _busy = false;

  Future<void> _continue() async {
    setState(() => _busy = true);
    await Permission.locationWhenInUse.request();
    if (!mounted) return;
    await ref.read(sessionProvider.notifier).markPermissionsExplained();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ready to take your first job.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'BTS uses your location to offer nearby deliveries anywhere in Ghana. Camera is used later for proof of delivery.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
              ),
              const Spacer(),
              const _Reason(
                icon: Icons.near_me_outlined,
                title: 'Location while using the app',
                body: 'So we can ping you for jobs near you and record the trip trail.',
              ),
              const SizedBox(height: 16),
              const _Reason(
                icon: Icons.photo_camera_outlined,
                title: 'Camera at drop-off',
                body: 'You will take a photo when the parcel is handed over. We ask then, not now.',
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _busy ? null : _continue,
                  child: Text(_busy ? 'Please wait…' : 'Continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Reason extends StatelessWidget {
  const _Reason({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: RiderColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(body, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: RiderColors.mutedText)),
            ],
          ),
        ),
      ],
    );
  }
}
