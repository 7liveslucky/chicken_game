import 'dart:math';
import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';

import 'main.dart';

class Egg {
  final randomNumberGenerator = Random();
  final ChickenGame chickenGame;
  bool stone;
  double speed;
  Rect eggRect;
  final List<Sprite> eggSprites = [
    Sprite('egg.png'),
    Sprite('egg_broken.png'),
    Sprite('egg-broken_yolk.png'),
  ];

  final List<Sprite> stonesSprites = [
    Sprite('Stone.png'),
    Sprite('Stone2.png'),
    Sprite('Stone3.png'),
    Sprite('corn.png'),
  ];
  int stoneIndex;

  Egg(this.chickenGame, double x) {
    speed = chickenGame.widthFactor * randomNumberGenerator.nextDouble() * (1 - 0.3 + 1) + 0.1;
    stone = randomNumberGenerator.nextBool();
    eggRect = Rect.fromLTWH(
        x, 0, chickenGame.widthFactor * 0.3, chickenGame.heightFactor * 0.6);
    stoneIndex=randomNumberGenerator.nextInt(3);
  }

  void render(Canvas canvas) {
    canvas.drawRect(eggRect, Paint()..color = Color(0x00000000));
    if (stone) {
      stonesSprites[stoneIndex].renderRect(canvas, eggRect.inflate(0));
    } else {
      if (eggRect.bottom > chickenGame.ground.top) {
        eggSprites[1].renderRect(canvas, eggRect.inflate(0));
      } else if (eggRect.bottom > chickenGame.ground.center.dy) {
        eggSprites[2].renderRect(canvas, eggRect.inflate(0));
      } else {
        eggSprites[0].renderRect(canvas, eggRect.inflate(0));
      }
    }
  }

  void update(double t) {
    double stepDistance = speed * t;
    Offset toBootm =
        Offset(eggRect.center.dx, chickenGame.shortEdge()) - eggRect.center;
    if (stepDistance <= toBootm.distance) {
      Offset stepTpPlayer =
          Offset.fromDirection(toBootm.direction, stepDistance);
      eggRect = eggRect.shift(stepTpPlayer);
    }
  }


}
