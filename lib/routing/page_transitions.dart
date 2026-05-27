import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const _tabDuration = Duration(milliseconds: 250);

/// Directional horizontal slide for bottom-tab switches.
Page<T> tabSlidePage<T>({
  required Widget child,
  required int fromIndex,
  required int toIndex,
  LocalKey? key,
}) {
  if (fromIndex == toIndex) {
    return NoTransitionPage<T>(key: key, child: child);
  }

  final forward = toIndex > fromIndex;
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: _tabDuration,
    reverseTransitionDuration: _tabDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final enterOffset = forward
          ? const Offset(1.0, 0.0)
          : const Offset(-1.0, 0.0);
      final exitOffset = forward
          ? const Offset(-0.25, 0.0)
          : const Offset(0.25, 0.0);

      return SlideTransition(
        position: Tween<Offset>(begin: enterOffset, end: Offset.zero).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
        ),
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset.zero, end: exitOffset).animate(
            CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInOutCubic,
            ),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Fade for splash / login.
Page<T> fadePage<T>({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Standard push from right (e.g. My Meters).
Page<T> pushPage<T>({
  required Widget child,
  LocalKey? key,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: _tabDuration,
    reverseTransitionDuration: _tabDuration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .animate(
          CurvedAnimation(parent: animation, curve: Curves.easeInOutCubic),
        ),
        child: child,
      );
    },
  );
}
