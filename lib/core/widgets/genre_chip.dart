import 'package:flutter/material.dart';

import '../../core/config/app_theme.dart';
import '../../core/config/mood_config.dart';

class GenreChip extends StatelessWidget {
  final int genreId;

  const GenreChip({super.key, required this.genreId});

  @override
  Widget build(BuildContext context) {
    final label = kGenreLabels[genreId] ?? '';
    if (label.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        border: Border.all(color: AppTheme.textMuted.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: 'SFProText',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
