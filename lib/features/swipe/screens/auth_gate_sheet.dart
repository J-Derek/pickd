import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_theme.dart';

/// Non-blocking auth gate shown after 5 swipes.
/// User can dismiss and continue as guest.
class AuthGateSheet extends StatelessWidget {
  const AuthGateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.bgMuted),
      ),
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.bgMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          // Amber glow icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.accentPrimary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.accentPrimary.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.favorite_border,
              color: AppTheme.accentPrimary,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Save your taste forever',
            style: TextStyle(
              fontFamily: 'Syne',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Create a free account to sync your watchlist, taste profile, and picks across devices.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          // Sign up CTA
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/auth');
            },
            child: const Text('Create free account'),
          ),
          const SizedBox(height: 12),
          // Dismiss — keep swiping
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Keep swiping as guest',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.textMuted,
                  decoration: TextDecoration.underline,
                  decorationColor: AppTheme.textMuted,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
