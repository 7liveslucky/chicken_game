import 'main.dart';

class EggsGenerator {
  final ChickenGame chickenGame;
  final int delayBetween = 4000;
  final int mindelayBetween = 500;
  final int spawnChange = 4;
  int current;
  int next;
  int maxEggs = 4;

  EggsGenerator(this.chickenGame) {
    init();
  }

  void init() {
    current = delayBetween;
    next = DateTime.now().microsecondsSinceEpoch + current;
  }

  void update(double t) {
    int now = DateTime.now().microsecondsSinceEpoch;
    chickenGame.eggBreaker();
    chickenGame.eggCatch();
    chickenGame.bulletEffect();
    if (chickenGame.eggs.length < maxEggs && now >= next) {
      chickenGame.eggLayer();
      if (current > mindelayBetween) {
        current -= spawnChange;
      }
    }
    if (chickenGame.eggs.length % 20 == 0 && chickenGame.eggs.length != 0) {
      maxEggs += (maxEggs / 4).floor();
    }
  }
}
