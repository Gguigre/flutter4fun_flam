import 'package:flam/main.dart';
import 'package:flutter/material.dart';

class ShrinkingCircles extends StatelessWidget {
  const ShrinkingCircles({
    Key? key,
    required this.gameState,
    required this.duration,
    required this.size,
  }) : super(key: key);

  final GameState gameState;
  final int duration;
  final double size;

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
        child: Stack(
          children: [
            new AnimatedContainer(
              width: computeSize(size),
              height: computeSize(size),
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(143, 196, 227, 1)),
              duration: Duration(seconds: duration),
            ),
            new AnimatedContainer(
              width: computeSize(size * 0.8),
              height: computeSize(size * 0.8),
              decoration: new BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromRGBO(175, 226, 247, 1)),
              duration: Duration(seconds: (duration * 0.8).toInt()),
            ),
          ],
          alignment: AlignmentDirectional.center,
        ),
        duration: Duration(seconds: duration),
        top: computeSize(-size / 2));
  }

  double computeSize(double max) => gameState == GameState.PLAYING ? 0 : max;
}
