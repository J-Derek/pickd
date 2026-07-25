import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/config/app_theme.dart';

/// Full-screen dialog for playing YouTube trailers with custom player controls and Pop-Out.
class TrailerFullScreenDialog extends StatefulWidget {
  final String videoId;

  const TrailerFullScreenDialog({super.key, required this.videoId});

  @override
  State<TrailerFullScreenDialog> createState() => _TrailerFullScreenDialogState();
}

class _TrailerFullScreenDialogState extends State<TrailerFullScreenDialog> {
  late YoutubePlayerController _controller;
  bool _isPlaying = true;
  bool _isMuted = false;

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

  void _togglePlay() async {
    final state = await _controller.playerState;
    if (state == PlayerState.playing) {
      _controller.pauseVideo();
      setState(() => _isPlaying = false);
    } else {
      _controller.playVideo();
      setState(() => _isPlaying = true);
    }
  }

  void _toggleMute() async {
    final isMuted = await _controller.isMuted;
    if (isMuted) {
      _controller.unMute();
      setState(() => _isMuted = false);
    } else {
      _controller.mute();
      setState(() => _isMuted = true);
    }
  }

  void _seekRelative(int seconds) async {
    final currentTime = await _controller.currentTime;
    _controller.seekTo(seconds: currentTime + seconds, allowSeekAhead: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Pop Out & Close buttons
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: AppTheme.bgSurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Pop Out button (returns 'popout')
                  InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop('popout');
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.accentPrimary, width: 1.5),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.picture_in_picture_alt_rounded, size: 18, color: AppTheme.accentPrimary),
                          SizedBox(width: 6),
                          Text(
                            'Pop-Out Mode',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Text(
                    'Trailer Player',
                    style: TextStyle(
                      fontFamily: 'Syne',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                    onPressed: () => Navigator.of(context).pop('close'),
                  ),
                ],
              ),
            ),

            // Video Player Center
            Expanded(
              child: Center(
                child: YoutubePlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                ),
              ),
            ),

            // Bottom Player Quick Controls Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppTheme.bgSurface,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Rewind 10s
                  IconButton(
                    icon: const Icon(Icons.replay_10_rounded, color: AppTheme.textPrimary, size: 28),
                    onPressed: () => _seekRelative(-10),
                  ),

                  // Play / Pause Toggle
                  Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.accentPrimary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        color: AppTheme.textInverse,
                        size: 30,
                      ),
                      onPressed: _togglePlay,
                    ),
                  ),

                  // Forward 10s
                  IconButton(
                    icon: const Icon(Icons.forward_10_rounded, color: AppTheme.textPrimary, size: 28),
                    onPressed: () => _seekRelative(10),
                  ),

                  // Mute / Unmute Toggle
                  IconButton(
                    icon: Icon(
                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: _isMuted ? AppTheme.destructiveRed : AppTheme.textPrimary,
                      size: 24,
                    ),
                    onPressed: _toggleMute,
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
