import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final masked = session.challenge?.maskedPhone ?? 'your phone';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: RiderColors.primaryWhite,
        foregroundColor: RiderColors.primaryBlack,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => ref.read(sessionProvider.notifier).clearChallenge(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter the 4-digit code', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'Sent to $masked. In local development the code is printed in the API terminal.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _code,
                autofocus: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 4,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: Theme.of(context).textTheme.displaySmall,
                decoration: const InputDecoration(counterText: '', hintText: '••••'),
                onChanged: (value) {
                  if (value.length == 4) {
                    ref.read(sessionProvider.notifier).verifyOtp(value);
                  }
                },
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
                      : () => ref.read(sessionProvider.notifier).verifyOtp(_code.text),
                  child: Text(session.busy ? 'Verifying…' : 'Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
