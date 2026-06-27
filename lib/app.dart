import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/config/app_theme.dart';
import 'features/onboarding/screens/splash_screen.dart';
import 'features/onboarding/screens/mood_selection_screen.dart';
import 'features/onboarding/screens/taste_profile_screen.dart';
import 'features/swipe/screens/swipe_screen.dart';
import 'features/detail/screens/movie_detail_screen.dart';
import 'features/watchlist/screens/watchlist_screen.dart';
import 'features/gems/screens/gems_screen.dart';
import 'features/shell/main_shell.dart';

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
      builder: (context, state) => const TasteProfileScreen(),
    ),
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/swipe',
          builder: (context, state) => const SwipeScreen(),
        ),
        GoRoute(
          path: '/watchlist',
          builder: (context, state) => const WatchlistScreen(),
        ),
        GoRoute(
          path: '/gems',
          builder: (context, state) => const GemsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/movie/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final movie = state.extra;
        return MovieDetailScreen(movieId: id, movieExtra: movie);
      },
    ),
  ],
);

class PickdApp extends StatelessWidget {
  const PickdApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'pickd',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
    );
  }
}
