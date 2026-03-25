import 'package:flutter/material.dart';

/// Push a new screen with a right-to-left slide transition.
void pushScreen(BuildContext ctx, Widget screen) {
  Navigator.of(ctx).push(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 450),
    pageBuilder: (_, __, ___) => screen,
    transitionsBuilder: (_, anim, __, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
      return SlideTransition(position: slide, child: child);
    },
  ));
}

/// Replace current route with a fade transition.
void replaceWithFade(BuildContext ctx, Widget screen) {
  Navigator.of(ctx).pushReplacement(PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 600),
    pageBuilder: (_, __, ___) => screen,
    transitionsBuilder: (_, anim, __, child) =>
        FadeTransition(opacity: anim, child: child),
  ));
}

/// Push a new screen and remove all previous routes (make it root).
void pushAsRoot(BuildContext ctx, Widget screen) {
  Navigator.of(ctx).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => screen),
    (route) => false,
  );
}
