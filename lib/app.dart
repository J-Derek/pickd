import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/app_theme.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/mood_selection_screen.dart';
import 'features/onboarding/screens/taste_profile_screen.dart';
import 'features/swipe/screens/swipe_screen.dart';
import 'features/detail/screens/movie_detail_screen.dart';
import 'features/watchlist/screens/watchlist_screen.dart';
import 'features/gems/screens/gems_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/swipe_history_screen.dart';
import 'features/shell/main_shell.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/auth/screens/reset_password_screen.dart';
import 'features/search/screens/search_screen.dart';
import 'features/detail/screens/tv_seasons_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/onboarding/mood',
      builder: (context, state) => const MoodSelectionScreen(),
    ),
    GoRoute(
      path: '/onboarding/taste',
      builder: (context, state) {
        final isEditing = state.extra == true;
        return TasteProfileScreen(isEditing: isEditing);
      },
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/swipe',
          builder: (context, state) => const SwipeScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/watchlist',
          builder: (context, state) => const WatchlistScreen(),
        ),
        GoRoute(
          path: '/gems',
          builder: (context, state) => const GemsScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/swipe-history',
      builder: (context, state) => const SwipeHistoryScreen(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordScreen(),
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final movie = state.extra;
        return MovieDetailScreen(movieId: id, movieExtra: movie);
      },
    ),
    GoRoute(
      path: '/tv/:id/seasons',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final title = state.extra as String?;
        return TvSeasonsScreen(seriesId: id, seriesName: title);
      },
    ),
  ],
);

class PickdApp extends ConsumerStatefulWidget {
  const PickdApp({super.key});

  @override
  ConsumerState<PickdApp> createState() => _PickdAppState();
}

class _PickdAppState extends ConsumerState<PickdApp> {
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    try {
      _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        if (data.event == AuthChangeEvent.passwordRecovery) {
          _router.go('/reset-password');
        }
      });
    } catch (_) {
      // Supabase uninitialized in test environment — safe to ignore
    }
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pickd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.trackpad,
        },
      ),
    );
  }
}
