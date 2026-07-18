import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../swipe/providers/swipe_provider.dart';

import '../../../core/services/supabase_db_service.dart';

import '../../swipe/screens/settings_sheet.dart';
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _displayName;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = ref.read(currentUserProvider);
    if (user != null && !user.isAnonymous) {
      try {
        final profileDetails = await ref.read(supabaseDbServiceProvider).getProfileDetails(user.id);
        if (profileDetails != null && mounted) {
          setState(() {
            _displayName = profileDetails['display_name'] as String?;
            _avatarUrl = profileDetails['avatar_url'] as String?;
          });
        }
      } catch (e) {
        // ignore
      }
    }
  }

  Future<void> _showEditProfileDialog() async {
    final nameCtrl = TextEditingController(text: _displayName);
    final avatarCtrl = TextEditingController(text: _avatarUrl);

    void showAvatarPicker(void Function(void Function()) setStateDialog) {
      final seeds = ['Jack', 'Luna', 'Felix', 'Jasper', 'Max', 'Abby', 'Simba', 'Loki', 'Bella', 'Charlie', 'Milo', 'Oliver'];
      showModalBottomSheet(
        context: context,
        backgroundColor: AppTheme.bgSurface,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose an Avatar', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: seeds.length,
                    itemBuilder: (context, index) {
                      final url = 'https://api.dicebear.com/7.x/bottts/png?seed=${seeds[index]}&backgroundColor=1f1f1f';
                      return GestureDetector(
                        onTap: () {
                          setStateDialog(() {
                            avatarCtrl.text = url;
                          });
                          Navigator.pop(ctx);
                        },
                        child: CircleAvatar(
                          backgroundColor: AppTheme.bgMuted,
                          backgroundImage: NetworkImage(url),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: AppTheme.bgSurface,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            title: const Text('Edit Profile', style: TextStyle(color: AppTheme.textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (avatarCtrl.text.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.bgMuted,
                      backgroundImage: NetworkImage(avatarCtrl.text),
                    ),
                  ),
                TextField(
                  controller: nameCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.bgMuted)),
                    focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.accentPrimary)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(LucideIcons.image, color: AppTheme.accentPrimary),
                    label: const Text('Choose Avatar', style: TextStyle(color: AppTheme.accentPrimary)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.bgMuted),
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => showAvatarPicker(setStateDialog),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
              TextButton(
                onPressed: () async {
                  final user = ref.read(currentUserProvider);
                  if (user != null && !user.isAnonymous) {
                    await ref.read(supabaseDbServiceProvider).updateProfileDetails(user.id, nameCtrl.text, avatarCtrl.text);
                    if (mounted) {
                      setState(() {
                        _displayName = nameCtrl.text.isNotEmpty ? nameCtrl.text : null;
                        _avatarUrl = avatarCtrl.text.isNotEmpty ? avatarCtrl.text : null;
                      });
                    }
                  }
                  if (ctx.mounted) Navigator.of(ctx).pop(true);
                },
                child: const Text('Save', style: TextStyle(color: AppTheme.accentPrimary)),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profile = HiveService.getProfile();
    
    final bool isGuest = user == null || user.isAnonymous;
    
    String displayEmail = 'Guest User';
    if (!isGuest) {
      if (user.email != null && user.email!.isNotEmpty) {
        displayEmail = user.email!;
      } else {
        displayEmail = 'Connected User';
      }
    }

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
                  _avatarUrl != null && _avatarUrl!.isNotEmpty
                      ? CircleAvatar(
                          radius: 30,
                          backgroundColor: AppTheme.bgMuted,
                          backgroundImage: NetworkImage(_avatarUrl!),
                        )
                      : const CircleAvatar(
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
                          _displayName ?? displayEmail,
                          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          !isGuest ? 'Cloud Sync Active' : 'Local device storage only',
                          style: const TextStyle(color: AppTheme.accentPrimary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            if (isGuest)
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
                      context.push('/onboarding/mood');
                    },
                    child: _StatCard(
                      icon: LucideIcons.film,
                      title: 'Favorite Titles',
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
              isDestructive: true,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppTheme.bgSurface,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    title: const Text('Reset Algorithm', style: TextStyle(color: AppTheme.textPrimary)),
                    content: const Text('This will clear all your swipe history and start fresh. Are you sure?', style: TextStyle(color: AppTheme.textSecondary)),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
                      TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Reset', style: TextStyle(color: AppTheme.accentSecondary))),
                    ],
                  ),
                );

                if (confirm == true) {
                  await HiveService.clearSwipeHistory();
                  final profile = HiveService.getProfile();
                  profile.totalSwipeCount = 0;
                  profile.suppressAuthGate = false;
                  await HiveService.saveProfile(profile);
                  
                  ref.read(swipeDeckProvider.notifier).resetSwipeGate();
                  ref.read(swipeDeckProvider.notifier).loadDeck();
                  
                  if (mounted) setState(() {});
                  
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Algorithm reset', style: TextStyle(color: AppTheme.textInverse)), backgroundColor: AppTheme.accentPrimary),
                    );
                  }
                }
              },
            ),
            
            if (!isGuest)
              _SettingsTile(
              icon: LucideIcons.user,
              title: 'Account Details',
              subtitle: 'Manage your name and avatar',
              onTap: () {
                if (isGuest) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please sign in to edit your profile', style: TextStyle(color: AppTheme.textInverse)),
                      backgroundColor: AppTheme.accentPrimary,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                } else {
                  _showEditProfileDialog();
                }
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
                activeThumbColor: AppTheme.accentPrimary,
              ),
              onTap: () {},
            ),

            if (!isGuest)
              _SettingsTile(
                icon: LucideIcons.logOut,
                title: 'Sign Out',
                subtitle: 'Disconnect your account from this device',
                isDestructive: true,
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      backgroundColor: AppTheme.bgSurface,
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      title: const Text('Sign Out', style: TextStyle(color: AppTheme.textPrimary)),
                      content: const Text('Are you sure you want to sign out?', style: TextStyle(color: AppTheme.textSecondary)),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary))),
                        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Sign Out', style: TextStyle(color: AppTheme.accentSecondary))),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    ref.read(authServiceProvider).signOut();
                  }
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
