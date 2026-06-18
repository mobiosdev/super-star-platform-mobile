import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Plays a network URL or bundled asset video (`assets/...`).
class AppVideoPlayer extends StatefulWidget {
  const AppVideoPlayer({
    super.key,
    required this.source,
    this.aspectRatio,
    this.autoPlay = false,
  });

  final String source;
  final double? aspectRatio;
  final bool autoPlay;

  static bool isAssetPath(String url) => url.startsWith('assets/');

  @override
  State<AppVideoPlayer> createState() => _AppVideoPlayerState();
}

class _AppVideoPlayerState extends State<AppVideoPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = AppVideoPlayer.isAssetPath(widget.source)
        ? VideoPlayerController.asset(widget.source)
        : VideoPlayerController.networkUrl(Uri.parse(widget.source));
    _init();
  }

  Future<void> _init() async {
    try {
      await _controller.initialize();
      if (widget.autoPlay) await _controller.play();
      if (mounted) setState(() => _initialized = true);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: ColoredBox(
          color: Colors.black12,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Could not play video\n$_error', textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }

    if (!_initialized) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 16 / 9,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller),
          _PlayPauseOverlay(controller: _controller),
        ],
      ),
    );
  }
}

class _PlayPauseOverlay extends StatefulWidget {
  const _PlayPauseOverlay({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_PlayPauseOverlay> createState() => _PlayPauseOverlayState();
}

class _PlayPauseOverlayState extends State<_PlayPauseOverlay> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final playing = widget.controller.value.isPlaying;
    return GestureDetector(
      onTap: () {
        playing ? widget.controller.pause() : widget.controller.play();
      },
      child: AnimatedOpacity(
        opacity: playing ? 0 : 1,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black26,
          alignment: Alignment.center,
          child: Icon(
            playing ? Icons.pause_circle_filled : Icons.play_circle_filled,
            size: 64,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
