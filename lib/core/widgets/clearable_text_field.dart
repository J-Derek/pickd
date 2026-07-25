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
        return Padding(
          padding: const EdgeInsets.only(right: 8.0),
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
                size: 13,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Standalone styled dark theme text input with built-in clear button
class ClearableTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final bool obscureText;
  final TextInputType? keyboardType;

  const ClearableTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        color: AppTheme.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          color: AppTheme.textMuted,
          fontSize: 15,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: ClearSuffixIcon(controller: controller),
        suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        filled: true,
        fillColor: AppTheme.bgSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.bgMuted),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.bgMuted),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.accentPrimary, width: 1.5),
        ),
      ),
    );
  }
}
