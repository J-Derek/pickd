import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Custom RootBackButtonDispatcher that intercepts Android system back gestures
/// before GoRouter Delegate drops them at top-level shell tab routes.
class PickdBackButtonDispatcher extends RootBackButtonDispatcher {
  final GoRouter router;

  PickdBackButtonDispatcher(this.router);

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    final rootNavigator = router.routerDelegate.navigatorKey.currentState;

    // 1. If root navigator can pop (pushed detail pages like /movie/:id), pop them standardly
    if (rootNavigator != null && rootNavigator.canPop()) {
      return rootNavigator.maybePop();
    }

    // 2. We are at a top-level tab route inside ShellRoute:
    final String location = router.routerDelegate.currentConfiguration.uri.path;
    const tabRoutes = ['/swipe', '/search', '/watchlist', '/gems', '/profile'];

    // If on a sub-tab, navigate back to /swipe (Discover Home)
    if (location != '/swipe' && tabRoutes.contains(location)) {
      router.go('/swipe');
      return true; // Handled! Prevents Android Activity exit
    }

    // 3. If on /swipe tab: invoke maybePop to trigger MainShell's PopScope exit dialog
    if (rootNavigator != null) {
      final popped = await rootNavigator.maybePop();
      if (popped) return true;
    }

    return false;
  }
}
