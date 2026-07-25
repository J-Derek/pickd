import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';
import '../../../core/services/hive_service.dart';
import '../../../core/services/supabase_auth_service.dart';
import '../../swipe/providers/swipe_provider.dart';
import '../../../core/services/supabase_db_service.dart';
import '../../../core/widgets/custom_snackbar.dart';

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

  void _showAvatarPickerSheet() {
    final seeds = [
      'Jack', 'Luna', 'Felix', 'Jasper', 'Max', 'Abby',
      'Simba', 'Loki', 'Bella', 'Charlie', 'Milo', 'Oliver'
    ];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.bgMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose Avatar',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: seeds.length,
              itemBuilder: (context, i) {
                final url = 'https://api.dicebear.com/7.x/bottts/png?seed=${seeds[i]}&backgroundColor=1f1f1f';
                return GestureDetector(
                  onTap: () async {
                    Navigator.pop(ctx);
                    final user = ref.read(currentUserProvider);
                    if (user != null && !user.isAnonymous) {
                      await ref.read(supabaseDbServiceProvider)
                          .updateProfileDetails(user.id, _displayName, url);
                    }
                    if (mounted) setState(() => _avatarUrl = url);
                  },
                  child: CircleAvatar(
                    backgroundColor: AppTheme.bgMuted,
                    backgroundImage: NetworkImage(url),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAccountDetailsSheet() {
    final nameCtrl = TextEditingController(text: _displayName);
    bool isEditingName = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateSheet) => Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.bgMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  Navigator.pop(ctx);
                  _showAvatarPickerSheet();
                },
                child: Stack(
                  children: [
                    _avatarUrl != null && _avatarUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: 44,
                            backgroundImage: NetworkImage(_avatarUrl!),
                          )
                        : const CircleAvatar(
                            radius: 44,
                            backgroundColor: AppTheme.bgMuted,
                            child: Icon(LucideIcons.user, size: 36, color: AppTheme.textSecondary),
                          ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.accentPrimary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _InfoRow(
                label: 'Email',
                value: ref.read(currentUserProvider)?.email ?? '—',
              ),
              const SizedBox(height: 16),
              if (!isEditingName)
                _InfoRow(
                  label: 'Username',
                  value: _displayName ?? 'Not set',
                  trailing: IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18, color: AppTheme.accentPrimary),
                    onPressed: () => setStateSheet(() => isEditingName = true),
                  ),
                )
              else
                TextField(
                  controller: nameCtrl,
                  autofocus: true,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.bgMuted),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppTheme.accentPrimary, width: 1.5),
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    foregroundColor: AppTheme.textInverse,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final user = ref.read(currentUserProvider);
                    if (user != null && !user.isAnonymous) {
                      final newName = nameCtrl.text.trim().isEmpty ? null : nameCtrl.text.trim();
                      await ref.read(supabaseDbServiceProvider)
                          .updateProfileDetails(user.id, newName, _avatarUrl);
                      if (mounted) setState(() => _displayName = newName);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save Changes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangePasswordSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.bgMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Change Password',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontFamily: 'Syne',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (errorMessage != null) ...[
                Text(
                  errorMessage!,
                  style: const TextStyle(color: AppTheme.accentSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
              ],
              TextField(
                controller: currentPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.bgMuted)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentPrimary)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.bgMuted)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentPrimary)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Confirm New Password',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.bgMuted)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: AppTheme.accentPrimary)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                          final currentPwd = currentPasswordController.text.trim();
                          final newPwd = newPasswordController.text.trim();
                          final confirmPwd = confirmPasswordController.text.trim();

                          if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
                            setSheetState(() => errorMessage = 'Please fill in all password fields.');
                            return;
                          }
                          if (newPwd.length < 6) {
                            setSheetState(() => errorMessage = 'New password must be at least 6 characters.');
                            return;
                          }
                          if (newPwd != confirmPwd) {
                            setSheetState(() => errorMessage = 'New passwords do not match.');
                            return;
                          }

                          setSheetState(() {
                            isLoading = true;
                            errorMessage = null;
                          });

                          try {
                            final user = ref.read(currentUserProvider);
                            if (user == null || user.email == null) {
                              throw 'User session invalid. Please log in again.';
                            }

                            // 1. Re-authenticate to verify current password
                            await ref.read(authServiceProvider).signInWithEmailPassword(
                                  user.email!,
                                  currentPwd,
                                );

                            // 2. Update password
                            await ref.read(authServiceProvider).updatePassword(newPwd);

                            if (context.mounted) {
                              showCustomSnackBar(
                                context,
                                message: 'Password changed successfully!',
                                isSuccess: true,
                              );
                              Navigator.of(context).pop();
                            }
                          } catch (e) {
                            setSheetState(() {
                              isLoading = false;
                              errorMessage = 'Current password incorrect or update failed.';
                            });
                          }
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Text(
                          'Update Password',
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final profile = HiveService.getProfile();
    final bool isGuest = user == null || user.isAnonymous;

    String resolvedName = 'Guest User';
    if (!isGuest) {
      if (_displayName != null && _displayName!.isNotEmpty) {
        resolvedName = _displayName!;
      } else if (user.email != null) {
        final prefix = user.email!.split('@').first;
        resolvedName = prefix.length > 12 ? prefix.substring(0, 12) : prefix;
      } else {
        resolvedName = 'Connected User';
      }
    }

    return Scaffold(
      backgroundColor: AppTheme.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Settings Header Title
              const Text(
                'Settings',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 24),

              // User Info Row
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (!isGuest) {
                        _showAvatarPickerSheet();
                      } else {
                        showCustomSnackBar(
                          context,
                          message: 'Please sign in to change your avatar',
                        );
                      }
                    },
                    child: Stack(
                      children: [
                        _avatarUrl != null && _avatarUrl!.isNotEmpty
                            ? CircleAvatar(
                                radius: 36,
                                backgroundColor: AppTheme.bgMuted,
                                backgroundImage: NetworkImage(_avatarUrl!),
                              )
                            : const CircleAvatar(
                                radius: 36,
                                backgroundColor: AppTheme.bgMuted,
                                child: Icon(LucideIcons.user, color: AppTheme.textSecondary, size: 36),
                              ),
                        if (!isGuest)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppTheme.accentPrimary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 10, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resolvedName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          !isGuest ? user.email ?? 'Cloud Sync Active' : 'Local device storage only',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Stats Cards
              _StatsSection(
                totalSwipes: profile.totalSwipeCount,
                totalFavorites: profile.tasteSeedMovieIds.length + profile.tasteSeedTvIds.length,
                onSwipesTap: () => context.push('/swipe-history'),
                onFavoritesTap: () => context.push('/onboarding/mood'),
              ),
              const SizedBox(height: 8),

              // ACCOUNT GROUP
              _SettingsGroup(
                title: 'Account',
                children: [
                  if (isGuest)
                    _SettingsRow(
                      icon: LucideIcons.userPlus,
                      title: 'Connect Account',
                      onTap: () => context.push('/auth'),
                    )
                  else ...[
                    _SettingsRow(
                      icon: LucideIcons.user,
                      title: 'Edit Profile Details',
                      onTap: _showAccountDetailsSheet,
                    ),
                    _SettingsRow(
                      icon: LucideIcons.keyRound,
                      title: 'Change Password',
                      onTap: _showChangePasswordSheet,
                    ),
                  ],
                  _SettingsRow(
                    icon: LucideIcons.rotateCcw,
                    title: 'Reset Swipe History',
                    isDestructive: true,
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          backgroundColor: AppTheme.bgSurface,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                          showCustomSnackBar(
                            context,
                            message: 'Algorithm reset successfully',
                            isSuccess: true,
                          );
                        }
                      }
                    },
                  ),
                  if (!isGuest)
                    _SettingsRow(
                      icon: LucideIcons.logOut,
                      title: 'Sign Out',
                      isDestructive: true,
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            backgroundColor: AppTheme.bgSurface,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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

              // PREFERENCES GROUP
              _SettingsGroup(
                title: 'Preferences',
                children: [
                  _SettingsRow(
                    icon: LucideIcons.bell,
                    title: 'Push Notifications',
                    trailing: Switch(
                      value: false,
                      onChanged: (val) {
                        showCustomSnackBar(
                          context,
                          message: 'Notifications coming soon',
                        );
                      },
                      activeThumbColor: AppTheme.textPrimary,
                      activeTrackColor: AppTheme.accentPrimary,
                      inactiveThumbColor: AppTheme.textMuted,
                      inactiveTrackColor: AppTheme.bgPrimary,
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                  _SettingsRow(
                    icon: LucideIcons.calendar,
                    title: 'Allow Classics (1990 & Older)',
                    trailing: Switch(
                      value: profile.allowOldMovies,
                      onChanged: (val) async {
                        setState(() {
                          profile.allowOldMovies = val;
                        });
                        await HiveService.saveProfile(profile);
                        final user = ref.read(currentUserProvider);
                        if (user != null && !user.isAnonymous) {
                          await ref.read(supabaseDbServiceProvider).updateAllowOldMovies(user.id, val);
                        }
                        ref.read(swipeDeckProvider.notifier).loadDeck();
                      },
                      activeThumbColor: AppTheme.textPrimary,
                      activeTrackColor: AppTheme.accentPrimary,
                      inactiveThumbColor: AppTheme.textMuted,
                      inactiveTrackColor: AppTheme.bgPrimary,
                      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                  _SettingsRow(
                    icon: LucideIcons.film,
                    title: 'Edit Taste Seeds',
                    onTap: () => context.push('/onboarding/mood'),
                  ),
                ],
              ),

              // SUPPORT GROUP
              _SettingsGroup(
                title: 'Support',
                children: [
                  _SettingsRow(
                    icon: LucideIcons.helpCircle,
                    title: 'Help Center',
                    onTap: () {
                      showCustomSnackBar(
                        context,
                        message: 'Help Center coming soon',
                      );
                    },
                  ),
                  _SettingsRow(
                    icon: LucideIcons.mail,
                    title: 'Send Feedback',
                    onTap: () {
                      showCustomSnackBar(
                        context,
                        message: 'Thank you for your feedback!',
                        isSuccess: true,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final int totalSwipes;
  final int totalFavorites;
  final VoidCallback onSwipesTap;
  final VoidCallback onFavoritesTap;

  const _StatsSection({
    required this.totalSwipes,
    required this.totalFavorites,
    required this.onSwipesTap,
    required this.onFavoritesTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.bgMuted.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: onSwipesTap,
              child: Column(
                children: [
                  Text(
                    '$totalSwipes',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total Swipes',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 1,
            height: 32,
            color: AppTheme.bgMuted.withValues(alpha: 0.5),
          ),
          Expanded(
            child: InkWell(
              onTap: onFavoritesTap,
              child: Column(
                children: [
                  Text(
                    '$totalFavorites',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Taste Seeds',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8, top: 24),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.bgSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.bgMuted.withValues(alpha: 0.5)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppTheme.bgMuted.withValues(alpha: 0.3),
                      indent: 16,
                      endIndent: 16,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: isDestructive
          ? BoxDecoration(
              color: AppTheme.accentSecondary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.accentSecondary.withValues(alpha: 0.2)),
            )
          : null,
      margin: isDestructive ? const EdgeInsets.symmetric(horizontal: 12, vertical: 4) : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive ? AppTheme.accentSecondary : AppTheme.textSecondary,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
                    color: isDestructive ? AppTheme.accentSecondary : AppTheme.textPrimary,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDestructive ? AppTheme.accentSecondary : AppTheme.textMuted,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Widget? trailing;
  const _InfoRow({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
