import 'package:flam/main.dart';
import 'package:flutter/material.dart';

class Instructions extends StatelessWidget {
  const Instructions({
    Key? key,
    required this.gameState,
  }) : super(key: key);

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        getInstructions(),
        textScaleFactor: 2.3,
        textAlign: TextAlign.center,
        style: TextStyle(
            color: Colors.white,
            fontFamily: 'Futura',
            fontWeight: FontWeight.bold),
      ),
    );
  }

  String getInstructions() {
    switch (gameState) {
      case GameState.READY:
        return "Souffle de manière continue sur la bougie. 💨";
      case GameState.PLAYING:
        return "Garde ton calme, tu t'en sors bien 👌";
      case GameState.FAILED:
        return "Souffle de manière continue la prochaine fois 😉";
      case GameState.SUCCESS:
        return "Bravo ! 🎉";
      case GameState.STOPPED:
      default:
        return "Allume la bougie lorsque tu es prête ! 🔥";
    }
  }
}
