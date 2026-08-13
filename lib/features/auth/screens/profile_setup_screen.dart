import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _first = TextEditingController();
  final _last = TextEditingController();

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('What should customers call you?', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'This is shown on the job when you accept a delivery.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _first,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'First name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _last,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'Last name'),
              ),
              if (session.error != null) ...[
                const SizedBox(height: 12),
                Text(session.error!, style: const TextStyle(color: RiderColors.danger)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: session.busy
                      ? null
                      : () {
                          ref.read(sessionProvider.notifier).completeProfile(
                                firstName: _first.text.trim(),
                                lastName: _last.text.trim(),
                              );
                        },
                  child: Text(session.busy ? 'Saving…' : 'Save and continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
