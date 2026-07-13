import 'package:flutter/material.dart';
import '../../../core/config/app_theme.dart';

class WalkthroughOverlay extends StatelessWidget {
  final VoidCallback onDismiss;

  const WalkthroughOverlay({super.key, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDismiss,
      child: Container(
        color: Colors.black.withValues(alpha: 0.75),
        child: const Stack(
          children: [
            // Top: Watched
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Icon(Icons.keyboard_arrow_up_rounded, color: AppTheme.accentGreen, size: 48),
                  Text('Mark as Watched', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Syne')),
                ],
              ),
            ),
            // Right: Save
            Positioned(
              right: 20,
              top: 300,
              child: Row(
                children: [
                  Text('Save to Watchlist', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Syne')),
                  Icon(Icons.keyboard_arrow_right_rounded, color: AppTheme.accentPrimary, size: 48),
                ],
              ),
            ),
            // Left: Skip
            Positioned(
              left: 20,
              top: 300,
              child: Row(
                children: [
                  Icon(Icons.keyboard_arrow_left_rounded, color: Colors.white70, size: 48),
                  Text('Skip', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Syne')),
                ],
              ),
            ),
            // Bottom text
            Positioned(
              bottom: 150,
              left: 20,
              right: 20,
              child: Text(
                'Tap anywhere to start swiping',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
