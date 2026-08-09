import 'package:flutter/material.dart';

import '../../../core/theme/rider_colors.dart';
import '../../../models/delivery_job.dart';

class DeliveryStepper extends StatelessWidget {
  const DeliveryStepper({super.key, required this.phase});

  final DeliveryPhase phase;

  static const _labels = ['Pickup', 'Collect', 'Drop-off', 'POD'];

  @override
  Widget build(BuildContext context) {
    final current = phase.stepIndex.clamp(0, 3);
    return Row(
      children: List.generate(_labels.length * 2 - 1, (i) {
        if (i.isOdd) {
          final after = i ~/ 2;
          final done = current > after;
          return Expanded(
            child: Container(
              height: 3,
              color: done ? RiderColors.primary : RiderColors.border,
            ),
          );
        }
        final index = i ~/ 2;
        final done = current > index;
        final active = current == index;
        return Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: done || active
                    ? RiderColors.primary
                    : RiderColors.primaryWhite,
                shape: BoxShape.circle,
                border: Border.all(
                  color: done || active
                      ? RiderColors.primary
                      : RiderColors.border,
                  width: 2,
                ),
              ),
              child: done
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: active
                            ? RiderColors.primaryWhite
                            : RiderColors.mutedText,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              _labels[index],
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: active || done
                    ? RiderColors.primaryBlack
                    : RiderColors.mutedText,
              ),
            ),
          ],
        );
      }),
    );
  }
}
