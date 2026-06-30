import 'package:flutter/material.dart';

class StoryViewScreen extends StatefulWidget {
  final String image;
  final String avatar;
  final String name;

  const StoryViewScreen({
    super.key,
    required this.image,
    required this.avatar,
    required this.name,
  });

  @override
  State<StoryViewScreen> createState() => _StoryViewScreenState();
}

class _StoryViewScreenState extends State<StoryViewScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      });
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dx = details.globalPosition.dx;
    if (dx < screenWidth / 3) {
      // Tap on left, we could go previous, but for now just restart animation
      _animationController.forward(from: 0.0);
    } else {
      // Tap on right, could go next, for now just complete to pop
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: (_) => _animationController.stop(),
        onLongPressEnd: (_) => _animationController.forward(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(widget.image, fit: BoxFit.cover),
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(widget.avatar),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 10,
              right: 10,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: _animationController.value,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 2,
                    borderRadius: BorderRadius.circular(2),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
