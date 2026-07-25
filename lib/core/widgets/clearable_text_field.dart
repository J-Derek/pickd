import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../config/app_theme.dart';

/// Reusable clear (X) suffix icon badge for any [TextEditingController].
class ClearSuffixIcon extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback? onCleared;
  final bool unfocusOnClear;

  const ClearSuffixIcon({
    super.key,
    required this.controller,
    this.onCleared,
    this.unfocusOnClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        if (value.text.isEmpty) return const SizedBox.shrink();
        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                controller.clear();
                if (unfocusOnClear) FocusScope.of(context).unfocus();
                onCleared?.call();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppTheme.bgMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.x,
                  size: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
