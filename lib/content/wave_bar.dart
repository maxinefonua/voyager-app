import 'package:flutter/material.dart';

class WaveBar extends StatefulWidget {
  final int index;
  const WaveBar({super.key, required this.index});

  @override
  State<WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    Future.delayed(Duration(milliseconds: widget.index * 150), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final opacity = (255 * (0.8 + (_controller.value * 0.2))).toInt();
        return Container(
          width: 4,
          height: 10 * (1 + _controller.value * 1.2),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Color.fromARGB(opacity, 255, 255, 255),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      },
    );
  }
}
