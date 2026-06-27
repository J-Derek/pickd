import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';
import '../../../core/services/hive_service.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Allow Classics (1990 & Older)',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textPrimary,
                ),
              ),
              Switch(
                value: _allowOldMovies,
                activeThumbColor: AppTheme.accentPrimary,
                onChanged: (val) {
                  setState(() {
                    _allowOldMovies = val;
                  });
                  final profile = HiveService.getProfile();
                  profile.allowOldMovies = val;
                  HiveService.saveProfile(profile);
                },
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
