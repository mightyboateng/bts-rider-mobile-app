import 'package:flutter/material.dart';

import '../core/theme/rider_colors.dart';
import '../core/utils/haptics.dart';

/// Bottom sheet with detents: drag freely, then it hits a stop and sits.
class DraggableRiderSheet extends StatefulWidget {
  const DraggableRiderSheet({
    super.key,
    required this.controller,
    required this.builder,
    this.minSize = 0.22,
    this.initialSize = 0.36,
    this.maxSize = 0.92,
    this.snapSizes = const [0.4, 0.88],
  });

  final DraggableScrollableController controller;
  final Widget Function(BuildContext context) builder;
  final double minSize;
  final double initialSize;
  final double maxSize;
  final List<double> snapSizes;

  @override
  State<DraggableRiderSheet> createState() => _DraggableRiderSheetState();
}

class _DraggableRiderSheetState extends State<DraggableRiderSheet> {
  double? _restingSnap;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onDrag);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.controller.isAttached) {
        _restingSnap = widget.controller.size;
      }
      _ready = true;
    });
  }

  @override
  void didUpdateWidget(covariant DraggableRiderSheet old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onDrag);
      widget.controller.addListener(_onDrag);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onDrag);
    super.dispose();
  }

  List<double> get _detents => [widget.minSize, ...widget.snapSizes, widget.maxSize];

  void _onDrag() {
    if (!_ready || !widget.controller.isAttached) return;
    final size = widget.controller.size;
    var nearest = _detents.first;
    for (final detent in _detents) {
      if ((detent - size).abs() < (nearest - size).abs()) nearest = detent;
    }
    if ((size - nearest).abs() < 0.01) {
      if (_restingSnap != nearest) {
        _restingSnap = nearest;
        RiderHaptics.medium();
      }
    } else if (_restingSnap != null && (size - _restingSnap!).abs() > 0.035) {
      _restingSnap = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DraggableScrollableSheet(
      controller: widget.controller,
      minChildSize: widget.minSize,
      initialChildSize: widget.initialSize,
      maxChildSize: widget.maxSize,
      snap: true,
      snapSizes: widget.snapSizes,
      snapAnimationDuration: const Duration(milliseconds: 160),
      shouldCloseOnMinExtent: false,
      builder: (context, scrollController) {
        return Material(
          color: RiderColors.primaryWhite,
          elevation: 12,
          shadowColor: Colors.black26,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: ListView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
              widget.builder(context),
            ],
          ),
        );
      },
    );
  }
}
