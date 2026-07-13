import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_theme.dart';

/// Main shell with bottom navigation bar wrapping the tab screens.
class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  static const _tabs = ['/swipe', '/watchlist', '/gems', '/profile'];

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
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppTheme.bgElevated,
            border: Border(
              top: BorderSide(color: AppTheme.bgMuted, width: 1),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64,
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.movie_filter_outlined,
                    activeIcon: Icons.movie_filter,
                    label: 'Discover',
                    isActive: index == 0,
                    onTap: () => context.go('/swipe'),
                  ),
                  _NavItem(
                    icon: Icons.bookmark_border,
                    activeIcon: Icons.bookmark,
                    label: 'Watchlist',
                    isActive: index == 1,
                    onTap: () => context.go('/watchlist'),
                  ),
                  _NavItem(
                    icon: Icons.auto_awesome_outlined,
                    activeIcon: Icons.auto_awesome,
                    label: 'Gems',
                    isActive: index == 2,
                    onTap: () => context.go('/gems'),
                    isGems: true,
                  ),
                  _NavItem(
                    icon: Icons.person_outline,
                    activeIcon: Icons.person,
                    label: 'Profile',
                    isActive: index == 3,
                    onTap: () => context.go('/profile'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isGems;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isGems = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: isActive
                    ? (isGems
                        ? AppTheme.accentPrimary.withValues(alpha: 0.12)
                        : AppTheme.accentPrimary.withValues(alpha: 0.12))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                size: 24,
                color: isActive
                    ? (isGems
                        ? const Color(0xFFBB86FC)
                        : AppTheme.accentPrimary)
                    : AppTheme.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
