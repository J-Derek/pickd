import 'package:flutter/material.dart';
import '../config/app_theme.dart';

void showCustomSnackBar(
  BuildContext context, {
  required String message,
  bool isError = false,
  bool isSuccess = false,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final iconColor = isError
      ? AppTheme.accentSecondary
      : (isSuccess ? AppTheme.accentGreen : AppTheme.accentPrimary);

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: AppTheme.bgElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.bgMuted.withValues(alpha: 0.6)),
      ),
      action: action,
      content: Row(
        children: [
          Icon(
            isError
                ? Icons.error_outline_rounded
                : (isSuccess ? Icons.check_circle_outline_rounded : Icons.info_outline_rounded),
            color: iconColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontFamily: 'Inter',
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
