import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;

  const AudioVisualizer({
    super.key,
    required this.isPlaying,
    this.barCount = 28,
    this.height = 42,
  });

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  late List<double> _barHeights;

  @override
  void initState() {
    super.initState();
    _barHeights = List.generate(
      widget.barCount,
      (_) => _random.nextDouble() * 0.7 + 0.3,
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..addListener(() {
        if (widget.isPlaying && mounted) {
          setState(() {
            for (int i = 0; i < widget.barCount; i++) {
              // Smooth dynamic wave height update
              _barHeights[i] = (_random.nextDouble() * 0.85 + 0.15);
            }
          });
        }
      });

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        setState(() {
          for (int i = 0; i < widget.barCount; i++) {
            _barHeights[i] = 0.15;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          final heightFactor = _barHeights[index];
          // Gradient variation across the bars
          final colorRatio = index / widget.barCount;
          final color = Color.lerp(
            AppTheme.primary,
            AppTheme.secondary,
            colorRatio,
          )!;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 3.5,
            height: widget.height * heightFactor,
            decoration: BoxDecoration(
              color: widget.isPlaying ? color : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              boxShadow: widget.isPlaying
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, -1),
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    );
  }
}
