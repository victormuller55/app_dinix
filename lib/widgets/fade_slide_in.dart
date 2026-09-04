import 'package:flutter/material.dart';

class FadeSlideIn extends StatelessWidget {
  final int index;
  final Widget child;

  const FadeSlideIn({
    super.key,
    required this.index,
    required this.child,
  });

  static const _durationMs = 220;
  static const _staggerMs = 90;
  static const _offsetY = 22.0;
  static const _maxStaggerIndex = 10;

  @override
  Widget build(BuildContext context) {
    final staggerIndex = index.clamp(0, _maxStaggerIndex);
    final delayMs = staggerIndex * _staggerMs;
    final totalMs = delayMs + _durationMs;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: totalMs),
      curve: Curves.linear,
      builder: (_, value, animatedChild) {
        final t = ((value * totalMs - delayMs) / _durationMs).clamp(0.0, 1.0);
        final curved = Curves.easeOutCubic.transform(t);
        return Opacity(
          opacity: curved,
          child: Transform.translate(
            offset: Offset(0, _offsetY * (1 - curved)),
            child: animatedChild,
          ),
        );
      },
      child: child,
    );
  }
}
