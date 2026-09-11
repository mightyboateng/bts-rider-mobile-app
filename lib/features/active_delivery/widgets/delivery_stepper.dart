import 'package:flutter/material.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../models/delivery_job.dart';

class DeliveryStepper extends StatelessWidget {
  const DeliveryStepper({super.key, required this.phase});

  final DeliveryPhase phase;

  static const _labels = ['Pickup', 'Collect', 'Drop-off', 'Pay & POD'];
  static const _duration = Duration(milliseconds: 380);

  @override
  Widget build(BuildContext context) {
    final current = phase.stepIndex.clamp(0, 3);
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final after = i ~/ 2;
          final done = current > after;
          return Expanded(
            child: Stack(
              children: [
                Container(height: 3, color: RiderColors.border),
                AnimatedFractionallySizedBox(
                  duration: _duration,
                  curve: Curves.easeOutCubic,
                  widthFactor: done ? 1 : 0,
                  alignment: Alignment.centerLeft,
                  child: Container(height: 3, color: RiderColors.primary),
                ),
              ],
            ),
          );
        }
        final index = i ~/ 2;
        final done = current > index;
        final active = current == index;
        return Column(
          children: [
            AnimatedContainer(
              duration: _duration,
              curve: Curves.easeOutBack,
              width: active ? 30 : 28,
              height: active ? 30 : 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done || active ? RiderColors.primary : RiderColors.primaryWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done || active ? RiderColors.primary : RiderColors.border,
                  width: 2,
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: RiderColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ]
                    : const [],
              ),
              child: AnimatedSwitcher(
                duration: _duration,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: done
                    ? const Icon(Icons.check, key: ValueKey('done'), size: 16, color: Colors.white)
                    : Text(
                        '${index + 1}',
                        key: const ValueKey('num'),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: active ? RiderColors.primaryWhite : RiderColors.mutedText,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: _duration,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active || done ? RiderColors.primaryBlack : RiderColors.mutedText,
              ),
              child: Text(_labels[index]),
            ),
          ],
        );
      }),
    );
  }
}
