import 'package:flutter/material.dart';

import '../core/theme/rider_colors.dart';

/// Bolt-style sheet: one scrollable owns the grabber and the body so drag
/// stays on a single controller and snaps without fighting nested lists.
class DraggableRiderSheet extends StatelessWidget {
  const DraggableRiderSheet({
    super.key,
    required this.controller,
    required this.builder,
    this.minSize = 0.22,
    this.initialSize = 0.36,
    this.maxSize = 0.92,
    this.snapSizes = const [0.28, 0.4, 0.88],
  });

  final DraggableScrollableController controller;
  final Widget Function(BuildContext context) builder;
  final double minSize;
  final double initialSize;
  final double maxSize;
  final List<double> snapSizes;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      controller: controller,
      minChildSize: minSize,
      initialChildSize: initialSize,
      maxChildSize: maxSize,
      snap: true,
      snapSizes: snapSizes,
      snapAnimationDuration: const Duration(milliseconds: 220),
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Material(
          color: RiderColors.primaryWhite,
          elevation: 16,
          shadowColor: Colors.black26,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16 + bottom),
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RiderColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              builder(context),
            ],
          ),
        );
      },
    );
  }
}
