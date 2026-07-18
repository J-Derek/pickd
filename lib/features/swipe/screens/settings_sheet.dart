import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/services/hive_service.dart';
import '../providers/swipe_provider.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  late bool _allowOldMovies;

  @override
  void initState() {
    super.initState();
    final profile = HiveService.getProfile();
    _allowOldMovies = profile.allowOldMovies;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              fontFamily: 'Syne',
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.bgElevated,
              borderRadius: BorderRadius.zero,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Allow Classics (1990 & Older)',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Switch(
                  value: _allowOldMovies,
                  activeThumbColor: AppTheme.textPrimary,
                  activeTrackColor: AppTheme.accentPrimary,
                  inactiveThumbColor: AppTheme.textMuted,
                  inactiveTrackColor: AppTheme.bgPrimary,
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                  onChanged: (val) {
                    setState(() {
                      _allowOldMovies = val;
                    });
                    final profile = HiveService.getProfile();
                    profile.allowOldMovies = val;
                    HiveService.saveProfile(profile);
                    
                    // Reload the deck immediately with the new setting
                    ref.read(swipeDeckProvider.notifier).loadDeck();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
