import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phone = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(sessionProvider.notifier).requestOtp(_phone.text.trim());
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
              Text('Rider sign in', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'We send a 4-digit code to your Ghanaian number. There is no password.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: const InputDecoration(
                  hintText: '024 123 4567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              if (session.error != null) ...[
                const SizedBox(height: 12),
                Text(session.error!, style: const TextStyle(color: RiderColors.danger)),
              ],
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: session.busy ? null : _submit,
                  child: Text(session.busy ? 'Sending…' : 'Send code'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
