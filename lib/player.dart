import 'dart:ui';

import 'main.dart';

class Player {
  final ChickenGame chickenGame;
  Rect playerRect;

  Player(this.chickenGame) {
    final width = chickenGame.widthFactor * 0.4;
    final height = chickenGame.heightFactor * 1.2;
    playerRect = Rect.fromLTWH(
        chickenGame.size.width / 2 - width / 2,
        chickenGame.size.height - (chickenGame.heightFactor * 2.2),
        width,
        height);
  }

  void render(Canvas canvas) {
    canvas.drawRect(
        playerRect, Paint()
      ..color = Color.fromARGB(255, 198, 175, 13));
  }

  void update(Canvas canvas) {

  }
}