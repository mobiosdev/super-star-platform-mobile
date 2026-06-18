import 'dart:async';
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_video_player.dart';

class FullscreenLivePlayerScreen extends StatefulWidget {
  const FullscreenLivePlayerScreen({super.key});

  @override
  State<FullscreenLivePlayerScreen> createState() => _FullscreenLivePlayerScreenState();
}

class _FullscreenLivePlayerScreenState extends State<FullscreenLivePlayerScreen> with TickerProviderStateMixin {
  final List<String> _mockComments = [
    'Omg is this real?! 😍',
    'Love the backstage vibe! ❤️',
    'Best artist ever!!!',
    'Wow, this clip is awesome! 🔥',
    'Can you play my favorite song next?',
    'Greetings from New York! 🗽',
    'This is amazing!',
    'So talented! 🙌',
    'Awesome stream!',
  ];

  final List<Map<String, String>> _chatMessages = [];
  final List<_FloatingHeart> _hearts = [];
  final TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _chatTimer;
  int _viewerCount = 1240;
  Timer? _viewerTimer;

  late VideoPlayerController _videoController;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initVideo();
    _startMockChat();
    _startViewerCountMock();
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset('assets/videos/my_clip.mp4');
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.play();
      if (mounted) {
        setState(() {
          _videoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing asset live video: $e. Trying network fallback.');
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'),
      );
      try {
        await _videoController.initialize();
        await _videoController.setLooping(true);
        await _videoController.play();
        if (mounted) {
          setState(() {
            _videoInitialized = true;
          });
        }
      } catch (e2) {
        debugPrint('Error initializing fallback network live video: $e2');
      }
    }
  }

  void _startMockChat() {
    // Initial messages
    _chatMessages.addAll([
      {'username': 'alex_99', 'message': 'Joined the stream! 👋'},
      {'username': 'music_lover', 'message': 'Wow, backstage access is epic!'},
    ]);

    _chatTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      final random = math.Random();
      final username = 'fan_${random.nextInt(1000)}';
      final message = _mockComments[random.nextInt(_mockComments.length)];
      _addChatMessage(username, message);
    });
  }

  void _startViewerCountMock() {
    _viewerTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted) return;
      final random = math.Random();
      setState(() {
        _viewerCount += random.nextInt(21) - 10; // fluctuation
      });
    });
  }

  void _addChatMessage(String username, String message) {
    setState(() {
      _chatMessages.add({'username': username, 'message': message});
    });
    // Auto scroll chat to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendUserComment() {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;
    _chatController.clear();
    _addChatMessage('You', text);
  }

  void _spawnHeart() {
    final random = math.Random();
    final controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    final heart = _FloatingHeart(
      controller: controller,
      startX: 50.0 + random.nextDouble() * 30.0,
      color: Colors.redAccent.withOpacity(0.85),
    );
    setState(() {
      _hearts.add(heart);
    });
    controller.forward().then((_) {
      controller.dispose();
      setState(() {
        _hearts.remove(heart);
      });
    });
  }

  @override
  void dispose() {
    _chatTimer?.cancel();
    _viewerTimer?.cancel();
    _chatController.dispose();
    _scrollController.dispose();
    _videoController.dispose();
    for (final h in _hearts) {
      h.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video background
          Positioned.fill(
            child: _videoInitialized
                ? Center(
                    child: AspectRatio(
                      aspectRatio: _videoController.value.aspectRatio,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),

          // Dark overlay gradient for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.4),
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Floating Hearts Animation overlay
          ..._hearts.map((heart) {
            return AnimatedBuilder(
              animation: heart.controller,
              builder: (context, child) {
                final progress = heart.controller.value;
                // Path curve calculations
                final y = (1.0 - progress) * MediaQuery.of(context).size.height * 0.4;
                final x = heart.startX + math.sin(progress * math.pi * 3) * 20;
                final scale = 1.0 - (progress * 0.3);
                final opacity = 1.0 - progress;

                return Positioned(
                  bottom: 80 + y,
                  right: x,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Icon(Icons.favorite, color: heart.color, size: 28),
                    ),
                  ),
                );
              },
            );
          }),

          // Upper UI: Live badge, Artist info, Viewer count, Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Creator Avatar & Name
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 14,
                          backgroundImage: CachedNetworkImageProvider('https://i.pravatar.cc/150?u=demo-artist'),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'For the Fans',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Live Stream',
                              style: GoogleFonts.poppins(
                                color: Colors.white70,
                                fontSize: 9,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // LIVE Pulsing Badge
                  const _LivePulsingBadge(),
                  const SizedBox(width: 8),

                  // Viewer Count
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.remove_red_eye_outlined, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '$_viewerCount',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),

          // Lower UI: Comments & Inputs
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scrolling Chat List
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.28,
                      child: ShaderMask(
                        shaderCallback: (rect) {
                          return const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black],
                            stops: [0.0, 0.2],
                          ).createShader(rect);
                        },
                        blendMode: BlendMode.dstIn,
                        child: ListView.builder(
                          controller: _scrollController,
                          itemCount: _chatMessages.length,
                          padding: const EdgeInsets.only(top: 24),
                          itemBuilder: (context, index) {
                            final msg = _chatMessages[index];
                            final isUser = msg['username'] == 'You';
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${msg['username']}: ',
                                    style: GoogleFonts.poppins(
                                      color: isUser ? Colors.amberAccent : Colors.cyanAccent,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      msg['message'] ?? '',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Inputs Row
                    Row(
                      children: [
                        // Chat Input Field
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: Colors.white30, width: 0.5),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    controller: _chatController,
                                    textInputAction: TextInputAction.send,
                                    onSubmitted: (_) => _sendUserComment(),
                                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
                                    decoration: const InputDecoration(
                                      hintText: 'Comment...',
                                      hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.send, color: AppColors.primary, size: 20),
                                  onPressed: _sendUserComment,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Heart Button for Floating Hearts effect
                        GestureDetector(
                          onTap: () {
                            _spawnHeart();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.redAccent,
                            ),
                            child: const Icon(Icons.favorite, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingHeart {
  _FloatingHeart({
    required this.controller,
    required this.startX,
    required this.color,
  });

  final AnimationController controller;
  final double startX;
  final Color color;
}

class _LivePulsingBadge extends StatefulWidget {
  const _LivePulsingBadge();

  @override
  State<_LivePulsingBadge> createState() => _LivePulsingBadgeState();
}

class _LivePulsingBadgeState extends State<_LivePulsingBadge> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.85 + _pulseController.value * 0.15),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(_pulseController.value * 0.6),
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
          ),
          child: Text(
            'LIVE',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
