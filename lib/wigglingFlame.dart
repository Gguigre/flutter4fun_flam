import 'package:flutter/material.dart';

class WigglingFlame extends StatelessWidget {
  const WigglingFlame({
    Key? key,
    required AnimationController controller,
  })  : _controller = controller,
        super(key: key);

  final AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      alignment: Alignment.bottomCenter,
      turns: Tween(begin: -0.15, end: 0.15).animate(_controller),
      child: Image.asset(
        "assets/images/Flame.png",
        scale: 1,
      ),
    );
  }
}
