import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../swipe/providers/swipe_provider.dart';

import '../../swipe/screens/settings_sheet.dart';
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profile = HiveService.getProfile();

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Your Profile', style: TextStyle(fontFamily: 'Syne', fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: const [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.bgSurface,
                borderRadius: BorderRadius.zero,
                border: Border.all(color: AppTheme.bgElevated),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: AppTheme.bgMuted,
                    child: Icon(LucideIcons.user, color: AppTheme.textSecondary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user != null ? (user.email ?? 'Connected User') : 'Guest User',
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user != null ? 'Supabase Cloud Sync active' : 'Local device storage only',
                          style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (user == null)
              Material(
                color: AppTheme.bgElevated,
                shape: Border.all(color: AppTheme.bgMuted),
                child: InkWell(
                  onTap: () => context.push('/auth'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: const Text('Connect Account', style: TextStyle(color: AppTheme.accentPrimary, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),

            const SizedBox(height: 32),
            const Text('Your Stats', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/swipe-history');
                    },
                    child: _StatCard(
                      icon: LucideIcons.mousePointer2,
                      title: 'Total Swipes',
                      value: profile.totalSwipeCount.toString(),
                      isClickable: true,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      context.push('/onboarding/taste', extra: true);
                    },
                    child: _StatCard(
                      icon: LucideIcons.film,
                      title: 'Taste Seeds',
                      value: (profile.tasteSeedMovieIds.length + profile.tasteSeedTvIds.length).toString(),
                      isClickable: true,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),
            const Text('Settings', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 12),

            _SettingsTile(
              icon: LucideIcons.settings,
              title: 'Preferences',
              subtitle: 'Change content filters and classic movies',
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SettingsSheet(),
                );
              },
            ),

            _SettingsTile(
              icon: LucideIcons.rotateCcw,
              title: 'Reset Swipe History',
              subtitle: 'Clear all swiped movies to start fresh',
              onTap: () async {
                // To be wired to Supabase later
                await HiveService.clearSwipeHistory();
                final profile = HiveService.getProfile();
                profile.totalSwipeCount = 0;
                await HiveService.saveProfile(profile);
                
                ref.read(swipeDeckProvider.notifier).resetSwipeGate();
                ref.read(swipeDeckProvider.notifier).loadDeck();
                
                setState(() {}); // Update the UI
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Algorithm reset', style: TextStyle(color: AppTheme.textInverse)), backgroundColor: AppTheme.accentPrimary),
                  );
                }
              },
            ),
            
            if (user != null)
              _SettingsTile(
              icon: LucideIcons.user,
              title: 'Account Details',
              subtitle: 'Manage your name and email',
              onTap: () {
                // TODO: Implement Account Details screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Account details coming soon', style: TextStyle(color: AppTheme.textInverse)),
                    backgroundColor: AppTheme.accentPrimary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            _SettingsTile(
              icon: LucideIcons.bell,
              title: 'Push Notifications',
              subtitle: 'Get alerts for new releases',
              trailing: Switch(
                value: false,
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications coming soon', style: TextStyle(color: AppTheme.textInverse)),
                      backgroundColor: AppTheme.accentPrimary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                activeColor: AppTheme.accentPrimary,
              ),
              onTap: () {},
            ),

            _SettingsTile(
              icon: LucideIcons.logOut,
                title: 'Sign Out',
                subtitle: 'Disconnect your account from this device',
                onTap: () {
                  ref.read(authServiceProvider).signOut();
                },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isClickable;

  const _StatCard({required this.icon, required this.title, required this.value, this.isClickable = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: AppTheme.bgMuted.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: AppTheme.accentPrimary, size: 24),
              if (isClickable)
                const Icon(Icons.edit, color: AppTheme.textSecondary, size: 16),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.bgElevated)),
        ),
        child: Row(
          children: [
            Icon(icon, color: isDestructive ? AppTheme.accentSecondary : AppTheme.textSecondary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: isDestructive ? AppTheme.accentSecondary : AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
            trailing ?? const Icon(LucideIcons.chevronRight, color: AppTheme.bgMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
