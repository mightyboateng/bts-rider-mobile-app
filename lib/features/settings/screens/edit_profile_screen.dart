import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../data/providers/session_provider.dart';
import '../../../widgets/rider_notice.dart';

class EditRiderProfileScreen extends ConsumerStatefulWidget {
  const EditRiderProfileScreen({super.key});

  @override
  ConsumerState<EditRiderProfileScreen> createState() => _EditRiderProfileScreenState();
}

class _EditRiderProfileScreenState extends ConsumerState<EditRiderProfileScreen> {
  late final TextEditingController _first;
  late final TextEditingController _last;

  @override
  void initState() {
    super.initState();
    final user = ref.read(sessionProvider).user;
    _first = TextEditingController(text: user?.firstName ?? '');
    _last = TextEditingController(text: user?.lastName ?? '');
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final first = _first.text.trim();
    final last = _last.text.trim();
    if (first.isEmpty || last.isEmpty) {
      showRiderNotice(context, message: 'Enter both your first and last name.', tone: RiderNoticeTone.error);
      return;
    }
    await ref.read(sessionProvider.notifier).completeProfile(firstName: first, lastName: last);
    if (!mounted) return;
    final error = ref.read(sessionProvider).error;
    if (error != null) {
      showRiderNotice(context, message: error, tone: RiderNoticeTone.error);
      return;
    }
    showRiderNotice(context, message: 'Profile updated.', tone: RiderNoticeTone.success);
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Update profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Text(
            'Customers see this name when you accept a job.',
            style: theme.textTheme.bodyLarge?.copyWith(color: RiderColors.mutedText),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _first,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'First name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _last,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Last name'),
          ),
          const SizedBox(height: 8),
          Text(session.user?.phone ?? '', style: theme.textTheme.bodySmall),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: session.busy ? null : _save,
              child: session.busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Save profile'),
            ),
          ),
        ],
      ),
    );
  }
}
