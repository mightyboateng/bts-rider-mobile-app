import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

/// Shared motion vocabulary for the rider app. Keep it light: entrances,
/// staggers and route fades; the job itself is the focus, not the chrome.
abstract final class RiderMotion {
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 480);
  static const Duration stagger = Duration(milliseconds: 45);
  static const Curve enter = Curves.easeOutCubic;
}

extension RiderEnterX on Widget {
  Widget enterUp({Duration? delay, double offset = 18}) {
    return animate(delay: delay)
        .fadeIn(duration: RiderMotion.base, curve: RiderMotion.enter)
        .moveY(begin: offset, end: 0, duration: RiderMotion.base, curve: RiderMotion.enter);
  }
}

/// Stagger a list of children in from below. Layout-only children
/// (`Spacer`, `Expanded`, empty `SizedBox`) are passed through untouched.
List<Widget> staggerIn(List<Widget> children, {Duration? initialDelay, double offset = 14}) {
  var index = 0;
  return [
    for (final child in children)
      if (_isLayoutOnly(child))
        child
      else
        child
            .animate(delay: (initialDelay ?? Duration.zero) + RiderMotion.stagger * index++)
            .fadeIn(duration: RiderMotion.base, curve: RiderMotion.enter)
            .moveY(begin: offset, end: 0, duration: RiderMotion.base, curve: RiderMotion.enter),
  ];
}

bool _isLayoutOnly(Widget child) {
  if (child is Spacer || child is Flexible) return true;
  if (child is SizedBox && child.child == null) return true;
  return false;
}

/// Fade-through page transition for top-level route changes.
CustomTransitionPage<T> fadeThroughPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: RiderMotion.base,
    reverseTransitionDuration: RiderMotion.fast,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: const Interval(0.3, 1, curve: Curves.easeOut));
      final scale = Tween<double>(begin: 0.96, end: 1).animate(
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}
