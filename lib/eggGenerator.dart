

import 'main.dart';

class EggsGenerator {
  final ChickenGame chickenGame;
  final int delayBetween = 4000;
  final int mindelayBetween = 500;
  final int spawnChange = 4;
  int current;
  int next;
  int maxEggs = 6;

  EggsGenerator(this.chickenGame) {
    init();
  }

  void init() {
    current = delayBetween;
    next = DateTime
        .now()
        .microsecondsSinceEpoch + current;
  }

  void update(double t) {
    int now = DateTime
        .now()
        .microsecondsSinceEpoch;
    chickenGame.eggBreaker();
    chickenGame.eggCatch();
    if (chickenGame.eggs.length < maxEggs && now >= next) {
      chickenGame.eggLayer();
      if (current > mindelayBetween) {
        current -= spawnChange;
      }
    }
  }
}