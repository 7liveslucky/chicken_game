import 'package:dart_git_fetchbylanguage/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Score {
  final ChickenGame chickenGame;
  TextPainter painter;
  Offset pos;
  int eggsCatched;
  int eggsMissed;
  int playerHealth;

  // int eggsMissed;

  Score(this.chickenGame) {
    painter = TextPainter(
        textAlign: TextAlign.center, textDirection: TextDirection.ltr);
    pos = Offset.zero;
  }

  void render(Canvas c) {
    painter.paint(c, pos);
  }

  void update(double t) {
    if (chickenGame.eggsCatched != eggsCatched ||
        eggsMissed != chickenGame.eggsMissed||
    playerHealth!=chickenGame.player.health
    ) {
      eggsCatched = chickenGame.eggsCatched;
      eggsMissed = chickenGame.eggsMissed;
      playerHealth=chickenGame.player.health;
      painter.text = TextSpan(children: [
        TextSpan(
          text: eggsCatched.toString() + " eggs\n",
          style: TextStyle(
              color: Colors.red, fontSize: chickenGame.widthFactor / 4),
        ),
        TextSpan(
          text: eggsMissed.toString() + " lives\n",
          style: TextStyle(
              color: Colors.red, fontSize: chickenGame.widthFactor / 4),
        ),
        TextSpan(
          text: playerHealth.toString() + " health points\n",
          style: TextStyle(
              color: Colors.red, fontSize: chickenGame.widthFactor / 4),
        ),
      ]);
      painter.layout();
    }
  }
}
