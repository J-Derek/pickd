import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:showcaseview/showcaseview.dart';

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
        body: ShowCaseWidget(
          builder: (context) => child,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            height: 64,
            decoration: const BoxDecoration(
              color: AppTheme.bgPrimary,
              border: Border(top: BorderSide(color: AppTheme.bgMuted, width: 1)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 0, index, Icons.movie_filter_outlined, Icons.movie_filter, 'Discover'),
                _buildNavItem(context, 1, index, LucideIcons.search, LucideIcons.search, 'Search'),
                _buildNavItem(context, 2, index, Icons.bookmark_border, Icons.bookmark, 'Watchlist'),
                _buildNavItem(context, 3, index, LucideIcons.gem, LucideIcons.gem, 'Gems'),
                _buildNavItem(context, 4, index, Icons.person_outline, Icons.person, 'Profile'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int itemIndex, int currentIndex, IconData icon, IconData activeIcon, String label) {
    final isSelected = itemIndex == currentIndex;
    final color = isSelected ? AppTheme.accentPrimary : AppTheme.textMuted;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go(_tabs[itemIndex]),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SFProText',
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 3,
              width: isSelected ? 16 : 0,
              decoration: BoxDecoration(
                color: AppTheme.accentPrimary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
