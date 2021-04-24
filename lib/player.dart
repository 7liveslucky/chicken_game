import 'dart:ui';

import 'package:flame/sprite.dart';

import 'main.dart';

class Player {
  final ChickenGame chickenGame;
  Rect playerRect;
  bool l;
  int health;

  final List<Sprite> chickenSprites = [
    Sprite('chicken_l.png'),
    Sprite('chicken_r.png'),
  ];

  Player(this.chickenGame) {
    final width = chickenGame.widthFactor * 0.4;
    final height = chickenGame.heightFactor * 1.2;
    playerRect = Rect.fromLTWH(
        chickenGame.size.width / 2 - width / 2,
        chickenGame.size.height - (chickenGame.heightFactor * 2),
        width,
        height);
    health = 100;
  }

  void render(Canvas canvas) {
    canvas.drawRect(playerRect, Paint()..color = Color(0x00000000));
    if (l == false) {
      chickenSprites[1].renderRect(canvas, playerRect.inflate(0));
    } else {
      chickenSprites[0].renderRect(canvas, playerRect.inflate(0));
    }
  }
}
