import 'package:flutter/material.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../core/utils/haptics.dart';

class SearchingRadar extends StatefulWidget {
  const SearchingRadar({
    super.key,
    required this.onGoOffline,
    this.onSimulatePing,
  });

  final VoidCallback onGoOffline;
  final VoidCallback? onSimulatePing;

  @override
  State<SearchingRadar> createState() => _SearchingRadarState();
}

class _SearchingRadarState extends State<SearchingRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        SizedBox(
          height: 120,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _RadarPainter(progress: _controller.value),
                child: const Center(
                  child: Icon(
                    Icons.radar,
                    size: 36,
                    color: RiderColors.primary,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Searching for orders...',
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Stay nearby — jobs ping with a 15s accept window.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  RiderHaptics.medium();
                  widget.onGoOffline();
                },
                child: const Text('GO OFFLINE'),
              ),
            ),
            if (widget.onSimulatePing != null) ...[
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: widget.onSimulatePing,
                  child: const Text('SIMULATE PING'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    for (var i = 0; i < 3; i++) {
      final t = ((progress + i / 3) % 1.0);
      final radius = 18 + t * 48;
      final paint = Paint()
        ..color = RiderColors.primary.withValues(alpha: (1 - t) * 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawCircle(center, radius, paint);
    }
    canvas.drawCircle(
      center,
      22,
      Paint()..color = RiderColors.primaryTint30,
    );
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
