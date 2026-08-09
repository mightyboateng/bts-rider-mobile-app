import 'package:flutter/material.dart';

import '../core/theme/rider_colors.dart';
import '../core/utils/haptics.dart';

/// Large outdoor-friendly swipe-to-confirm control.
class SwipeToConfirm extends StatefulWidget {
  const SwipeToConfirm({
    super.key,
    required this.label,
    required this.onConfirmed,
    this.enabled = true,
    this.backgroundColor = RiderColors.primary,
    this.trackColor,
  });

  final String label;
  final VoidCallback onConfirmed;
  final bool enabled;
  final Color backgroundColor;
  final Color? trackColor;

  @override
  State<SwipeToConfirm> createState() => _SwipeToConfirmState();
}

class _SwipeToConfirmState extends State<SwipeToConfirm>
    with SingleTickerProviderStateMixin {
  double _dx = 0;
  bool _done = false;
  static const double _thumb = 56;

  @override
  Widget build(BuildContext context) {
    final track = widget.trackColor ??
        Color.lerp(widget.backgroundColor, Colors.black, 0.12)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDx = (constraints.maxWidth - _thumb - 8).clamp(0.0, 600.0);
        final progress = maxDx == 0 ? 0.0 : (_dx / maxDx).clamp(0.0, 1.0);

        return Opacity(
          opacity: widget.enabled ? 1 : 0.45,
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Center(
                  child: Opacity(
                    opacity: (1 - progress * 1.4).clamp(0.0, 1.0),
                    child: Text(
                      widget.label.toUpperCase(),
                      style: const TextStyle(
                        color: RiderColors.primaryWhite,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 4 + _dx,
                  child: GestureDetector(
                    onHorizontalDragUpdate: widget.enabled && !_done
                        ? (details) {
                            setState(() {
                              _dx = (_dx + details.delta.dx).clamp(0.0, maxDx);
                            });
                            if (progress > 0.08) RiderHaptics.selection();
                          }
                        : null,
                    onHorizontalDragEnd: widget.enabled && !_done
                        ? (_) {
                            if (_dx >= maxDx * 0.85) {
                              setState(() {
                                _dx = maxDx;
                                _done = true;
                              });
                              RiderHaptics.heavy();
                              widget.onConfirmed();
                              Future<void>.delayed(
                                const Duration(milliseconds: 350),
                                () {
                                  if (mounted) {
                                    setState(() {
                                      _dx = 0;
                                      _done = false;
                                    });
                                  }
                                },
                              );
                            } else {
                              setState(() => _dx = 0);
                            }
                          }
                        : null,
                    child: Container(
                      width: _thumb,
                      height: _thumb,
                      decoration: BoxDecoration(
                        color: RiderColors.primaryWhite,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.chevron_right_rounded,
                        size: 32,
                        color: widget.backgroundColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
