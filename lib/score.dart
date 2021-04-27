import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'main.dart';

class Score {
  final ChickenGame chickenGame;
  TextPainter painterScore;
  TextPainter painterHealth;
  Offset posPainterScore;
  Offset posPainterHealth;
  int eggsCatched;
  int playerHealth;
  int maxLives;
  List<Rect> lives = [];
  Rect healthRect;
  Rect scoreRect;
  Sprite heartSprite = Sprite('heart.png');
  Sprite healthSprite = Sprite('health.png');
  Sprite scoreSprite = Sprite('score.png');

  // int eggsMissed;

  Score(this.chickenGame, this.maxLives) {
    painterHealth = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    painterScore = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);

    for (int i = 0; i <= maxLives; i++) {
      Rect rect = hearRect(i);
      lives.add(rect);
    }
    healthRect = Rect.fromLTWH(
        chickenGame.widthFactor * 0.2,
        chickenGame.heightFactor * 1.2,
        chickenGame.widthFactor * 0.4,
        chickenGame.heightFactor * 0.8);
    scoreRect = Rect.fromLTWH(
        chickenGame.widthFactor * 0.2,
        chickenGame.heightFactor * 2.4,
        chickenGame.widthFactor * 0.4,
        chickenGame.heightFactor * 0.8);
    posPainterHealth = Offset(healthRect.right, healthRect.top);
    posPainterScore = Offset(scoreRect.right, scoreRect.top);
  }

  Rect hearRect(int i) {
    if (i != 0) {
      return Rect.fromLTWH(
          0 +
              chickenGame.widthFactor * 0.2 +
              lives[i - 1].left +
              chickenGame.widthFactor * 0.2,
          0 + chickenGame.heightFactor * 0.2,
          chickenGame.widthFactor * 0.3,
          chickenGame.heightFactor * 0.6);
    }
    return Rect.fromLTWH(
        0 + chickenGame.widthFactor * 0.2,
        0 + chickenGame.heightFactor * 0.2,
        chickenGame.widthFactor * 0.3,
        chickenGame.heightFactor * 0.6);
  }

  void render(Canvas c) {
    lives.forEach((rect) {
      c.drawRect(rect, Paint()..color = Color(0x00000000));
      heartSprite.renderRect(c, rect.inflate(0));
    });
    c.drawRect(healthRect, Paint()..color = Color(0x00000000));
    healthSprite.renderRect(c, healthRect.inflate(0));
    c.drawRect(scoreRect, Paint()..color = Color(0x00000000));
    scoreSprite.renderRect(c, scoreRect.inflate(0));

    painterScore.paint(c, posPainterScore);
    painterHealth.paint(c, posPainterHealth);
  }

  void update(double t) {
    if (chickenGame.eggsCatched != eggsCatched) {
      eggsCatched = chickenGame.eggsCatched;
      painterScore.text = TextSpan(
        text: eggsCatched.toString(),
        style: TextStyle(
            color: Colors.orange,
            fontSize: chickenGame.widthFactor / 3,
            fontWeight: FontWeight.bold),
      );
      painterScore.layout();
    }
    if (playerHealth != chickenGame.player.health) {
      playerHealth = chickenGame.player.health;
      painterHealth.text = TextSpan(
        text: playerHealth.toString(),
        style: TextStyle(
            color: Colors.red,
            fontSize: chickenGame.widthFactor / 3,
            fontWeight: FontWeight.bold),
      );
      painterHealth.layout();
    }
  }
}
