import 'package:dart_git_fetchbylanguage/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Score {
  final ChickenGame chickenGame;
  TextPainter painter;
  Offset pos;
  int eggsCached;

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
    if ((painter.text ?? '') != chickenGame.eggsCatched.toString()) {
      painter.text = TextSpan(
        text: chickenGame.eggsCatched.toString()+String.fromCharCode(Icons.score.codePoint),
        style: TextStyle(color: Colors.red, fontSize: 100.0),
      );
      painter.layout();
      pos = Offset(chickenGame.size.width / 2 - painter.width / 2,
          chickenGame.size.height * 0.2 - painter.height / 2);
    }
  }
}
