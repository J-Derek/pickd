import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/config/app_theme.dart';

/// Full-screen dialog for playing YouTube trailers with a Pop-Out option.
class TrailerFullScreenDialog extends StatefulWidget {
  final String videoId;

  const TrailerFullScreenDialog({super.key, required this.videoId});

  @override
  State<TrailerFullScreenDialog> createState() => _TrailerFullScreenDialogState();
}

class _TrailerFullScreenDialogState extends State<TrailerFullScreenDialog> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: YoutubePlayer(
                controller: _controller,
                aspectRatio: 16 / 9,
              ),
            ),
            // Header Controls Bar
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pop Out button (returns 'popout')
                  ElevatedButton.icon(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop('popout');
                    },
                    icon: const Icon(Icons.picture_in_picture_alt_rounded, size: 16),
                    label: const Text(
                      'Pop Out',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.7),
                      foregroundColor: AppTheme.accentPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: AppTheme.accentPrimary, width: 1),
                      ),
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop('close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
