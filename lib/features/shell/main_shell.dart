import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/config/app_theme.dart';

/// Main shell with bottom navigation bar wrapping the tab screens.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = ['/swipe', '/search', '/watchlist', '/gems', '/profile'];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    return _tabs.indexOf(location).clamp(0, _tabs.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (index != 0) {
          context.go('/swipe');
          return;
        }
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppTheme.bgElevated,
            title: const Text('Exit Pickd?', style: TextStyle(color: Colors.white)),
            content: const Text('Are you sure you want to leave?', style: TextStyle(color: AppTheme.textSecondary)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Exit', style: TextStyle(color: AppTheme.accentPrimary)),
              ),
            ],
          ),
        );
        if (confirm == true) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.bgPrimary,
        body: child,
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: AppTheme.bgPrimary,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: index,
          selectedItemColor: AppTheme.accentPrimary,
          unselectedItemColor: AppTheme.textMuted,
          onTap: (i) => context.go(_tabs[i]),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.movie_filter_outlined),
              activeIcon: Icon(Icons.movie_filter),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.search),
              activeIcon: Icon(LucideIcons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              activeIcon: Icon(Icons.bookmark),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.gem),
              activeIcon: Icon(LucideIcons.gem),
              label: 'Gems',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
