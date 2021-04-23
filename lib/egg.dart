import 'dart:math';
import 'dart:ui';

import 'main.dart';

class Egg {
  final randomNumberGenerator = Random();
  final ChickenGame chickenGame;
  bool twoYolks;
  double speed;
  Rect eggRect;
  Random rand = Random();

  Egg(this.chickenGame, double x) {
    speed = chickenGame.widthFactor * rand.nextDouble() * (1 - 0.1 + 1) + 0.1;
    twoYolks = randomNumberGenerator.nextBool();
    eggRect = Rect.fromLTWH(
        x, 0, chickenGame.widthFactor * 0.8, chickenGame.heightFactor * 0.8);
  }

  void render(Canvas canvas) {
    canvas.drawRect(
        eggRect, Paint()..color = Color.fromARGB(255, 74, 122, 194));
  }

  void update(double t) {
    double stepDistance = speed * t;
    Offset toBootm =
        Offset(eggRect.center.dx, chickenGame.size.height) - eggRect.center;
    if (stepDistance <= toBootm.distance) {
      Offset stepTpPlayer =
          Offset.fromDirection(toBootm.direction, stepDistance);
      eggRect = eggRect.shift(stepTpPlayer);
    }
  }
}
