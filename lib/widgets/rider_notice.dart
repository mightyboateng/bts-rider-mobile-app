import 'dart:async';
import 'dart:io' show Platform;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/rider_colors.dart';

enum RiderNoticeTone { success, error, info }

bool get _ios => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

/// Platform notice. iOS uses a top banner with blur. Android uses a bottom snackbar.
void showRiderNotice(
  BuildContext context, {
  required String message,
  RiderNoticeTone tone = RiderNoticeTone.info,
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  final ios = _ios;
  switch (tone) {
    case RiderNoticeTone.success:
      HapticFeedback.lightImpact();
    case RiderNoticeTone.error:
      ios ? HapticFeedback.mediumImpact() : HapticFeedback.heavyImpact();
    case RiderNoticeTone.info:
      ios ? HapticFeedback.selectionClick() : HapticFeedback.lightImpact();
  }

  _RiderNoticeHost.show(
    overlay: overlay,
    message: message,
    tone: tone,
    ios: ios,
    hold: ios ? const Duration(milliseconds: 3200) : const Duration(milliseconds: 4200),
  );
}

class _RiderNoticeHost {
  static OverlayEntry? _entry;
  static Timer? _timer;

  static void show({
    required OverlayState overlay,
    required String message,
    required RiderNoticeTone tone,
    required bool ios,
    required Duration hold,
  }) {
    _timer?.cancel();
    _entry?.remove();
    final entry = OverlayEntry(
      builder: (context) => _NoticeCard(message: message, tone: tone, ios: ios, onDismiss: dismiss),
    );
    _entry = entry;
    overlay.insert(entry);
    _timer = Timer(hold, dismiss);
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _entry?.remove();
    _entry = null;
  }
}

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.message,
    required this.tone,
    required this.ios,
    required this.onDismiss,
  });

  final String message;
  final RiderNoticeTone tone;
  final bool ios;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final bottom = MediaQuery.paddingOf(context).bottom;
    final card = ios ? _ios(context) : _android(context);
    return Positioned(
      top: ios ? top + 8 : null,
      bottom: ios ? null : bottom + 16,
      left: ios ? 12 : 16,
      right: ios ? 12 : 16,
      child: card
          .animate()
          .fadeIn(duration: ios ? 280.ms : 200.ms, curve: Curves.easeOutCubic)
          .slideY(begin: ios ? -0.35 : 0.45, end: 0, duration: ios ? 280.ms : 200.ms, curve: Curves.easeOutCubic),
    );
  }

  Widget _ios(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, tint) = _icon();
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(color: tint.withValues(alpha: 0.16), shape: BoxShape.circle),
                      child: Icon(icon, size: 18, color: tint),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_title(), style: theme.textTheme.titleSmall),
                          const SizedBox(height: 2),
                          Text(message, style: theme.textTheme.bodySmall?.copyWith(color: const Color(0xFF3A3A3C))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _android(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, tint) = _icon();
    return Material(
      color: const Color(0xFF323232),
      elevation: 6,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onDismiss,
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 4, color: tint),
              const SizedBox(width: 12),
              Icon(icon, color: tint, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(message, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                ),
              ),
              IconButton(
                onPressed: onDismiss,
                icon: const Icon(Icons.close, color: Colors.white70, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (IconData, Color) _icon() {
    return switch (tone) {
      RiderNoticeTone.success => (Icons.check_circle_rounded, RiderColors.primary),
      RiderNoticeTone.error => (Icons.error_rounded, RiderColors.danger),
      RiderNoticeTone.info => (Icons.info_rounded, const Color(0xFF60A5FA)),
    };
  }

  String _title() {
    return switch (tone) {
      RiderNoticeTone.success => 'Done',
      RiderNoticeTone.error => 'Something went wrong',
      RiderNoticeTone.info => 'BTS Rider',
    };
  }
}
