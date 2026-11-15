import 'package:flutter/material.dart';
import '../providers/room_provider.dart';

class EmojiBurstOverlay extends StatelessWidget {
  final List<FloatingReaction> reactions;

  const EmojiBurstOverlay({super.key, required this.reactions});

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) return const SizedBox.shrink();

    return IgnorePointer(
      child: Stack(
        children: reactions.map((reaction) {
          return _FloatingEmojiItem(
            key: ValueKey(reaction.id),
            reaction: reaction,
          );
        }).toList(),
      ),
    );
  }
}

class _FloatingEmojiItem extends StatefulWidget {
  final FloatingReaction reaction;

  const _FloatingEmojiItem({super.key, required this.reaction});

  @override
  State<_FloatingEmojiItem> createState() => _FloatingEmojiItemState();
}

class _FloatingEmojiItemState extends State<_FloatingEmojiItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _translateY;
  late Animation<double> _opacity;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _translateY = Tween<double>(begin: 0.0, end: -350.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );

    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 25),
    ]).animate(_animController);

    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.9), weight: 50),
    ]).animate(_animController);

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final startLeft = widget.reaction.startX * size.width;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        return Positioned(
          bottom: 120 - _translateY.value,
          left: startLeft,
          child: Opacity(
            opacity: _opacity.value.clamp(0.0, 1.0),
            child: Transform.scale(
              scale: _scale.value,
              child: Text(
                widget.reaction.emoji,
                style: const TextStyle(fontSize: 38),
              ),
            ),
          ),
        );
      },
    );
  }
}
