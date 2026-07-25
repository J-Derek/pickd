import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../../core/config/app_theme.dart';

enum MiniPlayerSize { small, medium, large }

/// Draggable floating YouTube trailer player widget with 3 size presets and fullscreen expand.
class FloatingTrailerPlayer extends StatefulWidget {
  final String videoId;
  final VoidCallback onClose;
  final VoidCallback? onExpandToFullscreen;

  const FloatingTrailerPlayer({
    super.key,
    required this.videoId,
    required this.onClose,
    this.onExpandToFullscreen,
  });

  @override
  State<FloatingTrailerPlayer> createState() => _FloatingTrailerPlayerState();
}

class _FloatingTrailerPlayerState extends State<FloatingTrailerPlayer> {
  late YoutubePlayerController _controller;
  double _xPos = 16.0;
  double _yPos = 80.0;
  MiniPlayerSize _playerSize = MiniPlayerSize.medium;

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

  double _getWidth(double maxAvailableWidth) {
    switch (_playerSize) {
      case MiniPlayerSize.small:
        return 180.0;
      case MiniPlayerSize.medium:
        return 260.0;
      case MiniPlayerSize.large:
        return (maxAvailableWidth - 32.0).clamp(280.0, 340.0);
    }
  }

  void _cycleSize() {
    setState(() {
      if (_playerSize == MiniPlayerSize.small) {
        _playerSize = MiniPlayerSize.medium;
      } else if (_playerSize == MiniPlayerSize.medium) {
        _playerSize = MiniPlayerSize.large;
      } else {
        _playerSize = MiniPlayerSize.small;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final width = _getWidth(screenSize.width);
    final height = width * (9 / 16);

    final clampedRight = _xPos.clamp(12.0, screenSize.width - width - 12.0);
    final clampedBottom = _yPos.clamp(16.0, screenSize.height - height - 60.0);

    return Positioned(
      right: clampedRight,
      bottom: clampedBottom,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _xPos -= details.delta.dx;
            _yPos -= details.delta.dy;
          });
        },
        child: Material(
          elevation: 12,
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.accentPrimary.withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.7),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),
                // Controls Bar Overlay
                Positioned(
                  top: 4,
                  left: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Drag Indicator Handle
                        Row(
                          children: [
                            const Icon(Icons.drag_indicator_rounded, color: AppTheme.textMuted, size: 16),
                            Text(
                              _playerSize == MiniPlayerSize.small
                                  ? 'S'
                                  : _playerSize == MiniPlayerSize.medium
                                      ? 'M'
                                      : 'L',
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.accentPrimary,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Size Cycle Button
                            GestureDetector(
                              onTap: _cycleSize,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.aspect_ratio_rounded, color: Colors.white, size: 16),
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Fullscreen Button
                            if (widget.onExpandToFullscreen != null)
                              GestureDetector(
                                onTap: widget.onExpandToFullscreen,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 18),
                                ),
                              ),
                            const SizedBox(width: 4),
                            // Close Button
                            GestureDetector(
                              onTap: widget.onClose,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
