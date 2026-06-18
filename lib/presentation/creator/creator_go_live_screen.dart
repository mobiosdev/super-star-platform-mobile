import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../data/repositories/creator_studio_repository_impl.dart';

/// Artist Go Live — camera preview + live broadcast controls.
class CreatorGoLiveScreen extends ConsumerStatefulWidget {
  const CreatorGoLiveScreen({super.key});

  @override
  ConsumerState<CreatorGoLiveScreen> createState() => _CreatorGoLiveScreenState();
}

class _CreatorGoLiveScreenState extends ConsumerState<CreatorGoLiveScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  bool _initializing = true;
  String? _error;
  bool _isLive = false;
  bool _micEnabled = true;
  bool _startingLive = false;
  Duration _liveDuration = Duration.zero;
  Timer? _liveTimer;
  final _titleController = TextEditingController(text: 'Live with my fans');
  final _messageController = TextEditingController(text: "I'm going live now — join me!");
  final _streamUrlController = TextEditingController();
  int? _fansNotified;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
    _checkExistingLive();
  }

  Future<void> _checkExistingLive() async {
    try {
      final dash = await ref.read(creatorStudioRepositoryProvider).getDashboard();
      if (dash.live?.isLive == true && mounted) {
        setState(() => _isLive = true);
        _liveTimer?.cancel();
        _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (mounted) setState(() => _liveDuration += const Duration(seconds: 1));
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveTimer?.cancel();
    _titleController.dispose();
    _messageController.dispose();
    _streamUrlController.dispose();
    _disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed && !_isLive) {
      _initCamera();
    }
  }

  Future<void> _disposeCamera() async {
    final c = _controller;
    _controller = null;
    if (c != null) await c.dispose();
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    final camStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();
    if (!camStatus.isGranted) {
      setState(() {
        _initializing = false;
        _error = 'Camera permission is required to go live.';
      });
      return;
    }
    if (!micStatus.isGranted) {
      setState(() {
        _initializing = false;
        _error = 'Microphone permission is required for live audio.';
      });
      return;
    }

    try {
      await _disposeCamera();
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        setState(() {
          _initializing = false;
          _error = 'No camera found on this device.';
        });
        return;
      }

      final frontIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.front);
      _cameraIndex = frontIndex >= 0 ? frontIndex : 0;

      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: _micEnabled,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      _controller = controller;
      setState(() => _initializing = false);
    } catch (e) {
      setState(() {
        _initializing = false;
        _error = 'Could not open camera: $e';
      });
    }
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _isLive) return;
    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    setState(() => _initializing = true);
    try {
      await _disposeCamera();
      final controller = CameraController(
        _cameras[_cameraIndex],
        ResolutionPreset.high,
        enableAudio: _micEnabled,
      );
      await controller.initialize();
      if (!mounted) return;
      _controller = controller;
    } catch (e) {
      _error = 'Failed to switch camera: $e';
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _toggleMic() async {
    if (_isLive) return;
    setState(() => _micEnabled = !_micEnabled);
    await _initCamera();
  }

  Future<void> _startLive() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a stream title')),
      );
      return;
    }

    setState(() => _startingLive = true);
    try {
      final result = await ref.read(creatorStudioRepositoryProvider).startGoLive(
            title: title,
            message: _messageController.text.trim(),
            streamUrl: _streamUrlController.text.trim().isEmpty
                ? null
                : _streamUrlController.text.trim(),
          );
      _fansNotified = result.fansNotified;

      _liveTimer?.cancel();
      _liveDuration = Duration.zero;
      _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _liveDuration += const Duration(seconds: 1));
      });

      if (mounted) {
        setState(() {
          _isLive = true;
          _startingLive = false;
        });
        HapticFeedback.mediumImpact();
        final count = _fansNotified;
        if (count != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Live started — $count fans notified')),
          );
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _startingLive = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _startingLive = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _endLive() async {
    try {
      await ref.read(creatorStudioRepositoryProvider).endGoLive();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    }
    _liveTimer?.cancel();
    await _disposeCamera();
    if (mounted) context.pop();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return _ErrorView(message: _error!, onRetry: _initCamera, onClose: () => context.pop());
    }

    if (_initializing || _controller == null || !_controller!.value.isInitialized) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Opening camera…', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        _CameraPreviewArea(controller: _controller!),
        SafeArea(
          child: Column(
            children: [
              _TopBar(
                isLive: _isLive,
                duration: _formatDuration(_liveDuration),
                onClose: _isLive ? null : () => context.pop(),
              ),
              const Spacer(),
              _BottomControls(
                isLive: _isLive,
                startingLive: _startingLive,
                titleController: _titleController,
                messageController: _messageController,
                streamUrlController: _streamUrlController,
                micEnabled: _micEnabled,
                onFlip: _flipCamera,
                onToggleMic: _toggleMic,
                onGoLive: _startLive,
                onEndLive: _endLive,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CameraPreviewArea extends StatelessWidget {
  const _CameraPreviewArea({required this.controller});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isLive,
    required this.duration,
    this.onClose,
  });

  final bool isLive;
  final String duration;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: Colors.white),
            )
          else
            const SizedBox(width: 48),
          const Spacer(),
          if (isLive) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LIVE · $duration',
                    style: GoogleFonts.roboto(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Text(
              'Preview',
              style: GoogleFonts.roboto(color: Colors.white70, fontSize: 14),
            ),
          const Spacer(),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _BottomControls extends StatelessWidget {
  const _BottomControls({
    required this.isLive,
    required this.startingLive,
    required this.titleController,
    required this.messageController,
    required this.streamUrlController,
    required this.micEnabled,
    required this.onFlip,
    required this.onToggleMic,
    required this.onGoLive,
    required this.onEndLive,
  });

  final bool isLive;
  final bool startingLive;
  final TextEditingController titleController;
  final TextEditingController messageController;
  final TextEditingController streamUrlController;
  final bool micEnabled;
  final VoidCallback onFlip;
  final VoidCallback onToggleMic;
  final VoidCallback onGoLive;
  final VoidCallback onEndLive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isLive) ...[
            TextField(
              controller: titleController,
              style: GoogleFonts.roboto(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Stream title',
                hintStyle: GoogleFonts.roboto(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: messageController,
              style: GoogleFonts.roboto(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Message to fans',
                hintStyle: GoogleFonts.roboto(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: streamUrlController,
              style: GoogleFonts.roboto(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Stream URL (optional)',
                hintStyle: GoogleFonts.roboto(color: Colors.white54),
                filled: true,
                fillColor: Colors.white.withOpacity(0.12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _ControlButton(
                  icon: Icons.flip_camera_ios_rounded,
                  label: 'Flip',
                  onTap: onFlip,
                ),
                const SizedBox(width: 24),
                _ControlButton(
                  icon: micEnabled ? Icons.mic : Icons.mic_off,
                  label: micEnabled ? 'Mic on' : 'Mic off',
                  onTap: onToggleMic,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: startingLive
                  ? null
                  : isLive
                      ? onEndLive
                      : onGoLive,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLive ? Colors.grey.shade800 : AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: Icon(isLive ? Icons.stop_circle_outlined : Icons.sensors_rounded),
              label: Text(
                startingLive
                    ? 'Starting…'
                    : isLive
                        ? 'End stream'
                        : 'Go Live',
                style: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(height: 6),
            Text(label, style: GoogleFonts.roboto(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
    required this.onClose,
  });

  final String message;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(color: Colors.white),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
            TextButton(onPressed: onClose, child: const Text('Close')),
          ],
        ),
      ),
    );
  }
}
