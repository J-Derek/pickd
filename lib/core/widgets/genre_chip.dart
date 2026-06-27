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
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
