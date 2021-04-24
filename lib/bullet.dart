import 'dart:math';
import 'dart:ui';

import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class Bullet {
  final randomNumberGenerator = Random();
  final ChickenGame chickenGame;
  double speed;
  Rect bulletRect;
  bool heat;
  List<Sprite> bulletSprites = [
    Sprite('fire.gif'),
    Sprite('fire_start.png'),
  ];

  Bullet(this.chickenGame, double x) {
    speed = chickenGame.widthFactor * 4.0;
    bulletRect = Rect.fromLTWH(x, chickenGame.player.playerRect.center.dy,
        chickenGame.widthFactor * 0.3, chickenGame.heightFactor * 0.6);
    heat=false;
  }

  void render(Canvas canvas) {
    canvas.drawRect(bulletRect, Paint()..color = Color(0x00000000));
    if (!heat) {
      bulletSprites[1].renderRect(canvas, bulletRect.inflate(0));
    } else {
      bulletSprites[0].renderRect(canvas, bulletRect.inflate(0));
    }
  }

  void update(double t) {
    double stepDistance = speed * t;
    Offset toTop = Offset(bulletRect.center.dx, 0) - bulletRect.center;
    if (stepDistance <= toTop.distance) {
      Offset stepTpPlayer = Offset.fromDirection(toTop.direction, stepDistance);
      bulletRect = bulletRect.shift(stepTpPlayer);
    }
  }
}
