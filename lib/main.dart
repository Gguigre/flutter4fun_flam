import 'dart:async';
import 'dart:math';

import 'package:flam/header.dart';
import 'package:flam/instructions.dart';
import 'package:flam/shrinkingCircles.dart';
import 'package:flam/wigglingFlame.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:noise_meter/noise_meter.dart';

import 'config.dart' as Constants;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  late GameState gameState;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  List<NoiseReading> lastReadings = [];
  late AnimationController _controller;
  late Timer blowingTimer;

  @override
  void initState() {
    super.initState();
    gameState = GameState.STOPPED;
    _noiseMeter = new NoiseMeter(onError);
    _controller = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void startGame() {
    if (gameState == GameState.SUCCESS) {
      resetGame();
    }
    setState(() {
      gameState = GameState.READY;
    });
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      print(err);
    }
  }

  void onData(NoiseReading noiseReading) {
    this.setState(() {
      if (gameState == GameState.READY &&
          noiseReading.meanDecibel > Constants.BLOWING_THRESHOLD &&
          lastReadings.length == Constants.BUFFER_SIZE) {
        onBlowStart();
      }

      if (gameState == GameState.PLAYING &&
          noiseReading.meanDecibel < Constants.FAILURE_THRESHOLD &&
          lastReadings.length == Constants.BUFFER_SIZE) {
        onFail();
      }

      lastReadings.add(noiseReading);
      if (lastReadings.length > Constants.BUFFER_SIZE) {
        lastReadings.removeAt(0);
      }

      List<double> wigglingValues = [
        (noiseReading.maxDecibel) / 100,
        1 - ((noiseReading.maxDecibel) / 100)
      ];

      _controller.repeat(
          min: min(wigglingValues[0], wigglingValues[1]),
          max: max(wigglingValues[0], wigglingValues[1]),
          reverse: true);
    });
  }

  onSuccess() {
    gameState = GameState.SUCCESS;
    lastReadings = [];
  }

  onBlowStart() {
    setState(() {
      gameState = GameState.PLAYING;
      lastReadings = [];
      blowingTimer = Timer(Duration(seconds: Constants.BLOWING_TIME), () {
        onSuccess();
      });
    });
  }

  onFail() {
    setState(() {
      gameState = GameState.FAILED;
      lastReadings = [];
      blowingTimer.cancel();
    });
  }

  resetGame() {
    setState(() {
      gameState = GameState.STOPPED;
      lastReadings = [];
    });
  }

  void onError(PlatformException e) {
    print(e.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(74, 126, 163, 1),
      body: Center(
        child: Column(
          children: [
            Header(),
            Instructions(gameState: gameState),
            Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 64),
              child: Stack(
                alignment: AlignmentDirectional.topCenter,
                children: [
                  ShrinkingCircles(
                    gameState: gameState,
                    duration: Constants.BLOWING_TIME,
                    size: 250,
                  ),
                  Positioned(
                    child: Opacity(
                      opacity: gameState != GameState.STOPPED ? 1 : 0,
                      child: WigglingFlame(controller: _controller),
                    ),
                    top: -50,
                  ),
                  GestureDetector(
                    onTap: startGame,
                    child: Image.asset("assets/images/Candle.png"),
                  ),
                ],
                clipBehavior: Clip.none,
              ),
            )
          ],
        ),
      ),
    );
  }
}

enum GameState { STOPPED, READY, PLAYING, FAILED, SUCCESS }
