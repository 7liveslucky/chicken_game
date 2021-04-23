import 'dart:math';

import 'package:dart_git_fetchbylanguage/egg.dart';
import 'package:dart_git_fetchbylanguage/player.dart';
import 'package:dart_git_fetchbylanguage/score.dart';
import 'package:flame/flame.dart';
import 'package:flame/gestures.dart';
import 'package:flame/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'eggGenerator.dart';

import 'package:flame/game.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var flameUtil = Util();
  await flameUtil.setOrientation(DeviceOrientation.landscapeRight);
  await flameUtil.fullScreen();
  var game = new ChickenGame();
  game.init();
  runApp(game.widget);
  PanGestureRecognizer panreg = PanGestureRecognizer();
  panreg.onUpdate = game.onPanUpdate;
  DoubleTapGestureRecognizer dtreg = DoubleTapGestureRecognizer();
  dtreg.onDoubleTap = game.onDoubleTap;
}

class ChickenGame extends Game with PanDetector, DoubleTapDetector {
  Size size;
  double widthFactor;
  double heightFactor;
  Player player;
  List<Egg> eggs;
  EggsGenerator eggsGenerator;
  Random rand;
  Rect ground;
  int eggsCatched;
  int eggsMissed;
  Score score;

  Future<void> init() async {
    size = await Flame.util.initialDimensions();
    rand = Random();
    widthFactor = size.width / 10;
    heightFactor = size.height / 10;
    player = Player(this);
    eggs = [];
    eggsGenerator = EggsGenerator(this);
    eggsMissed=0;
    eggsCatched=0;
    score=Score(this);
  }

  @override
  void render(Canvas canvas) {
    ground =
        Rect.fromLTWH(0, size.height - heightFactor, size.width, heightFactor);
    if (size == null) {
      return;
    }
    canvas.drawRect(
        Rect.largest, Paint()..color = Color.fromARGB(255, 165, 194, 74));
    canvas.drawRect(
        ground, Paint()..color = Color.fromARGB(255, 139, 143, 126));
    player.render(canvas);
    eggs.forEach((egg) => egg.render(canvas));
    score.render(canvas);
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    final delta = details.delta;
    double translateX = delta.dx;
    if (player.playerRect.right + delta.dx >= size.width) {
      translateX = size.width - player.playerRect.right;
    } else if (player.playerRect.left + delta.dx <= 0) {
      translateX = -player.playerRect.left;
    }
    player.playerRect = player.playerRect.translate(translateX, 0);
  }

  @override
  void onDoubleTap() {}

  @override
  void update(double t) {
    eggsGenerator.update(t);
    eggs.forEach((egg) => egg.update(t));
    score.update(t);
  }

  void eggLayer() {
    eggs.add(Egg(this, rand.nextDouble() * size.width));
  }
  void eggCatch() {
    var toRemove = [];
    eggs.forEach((egg) {
      if (egg.eggRect.overlaps(player.playerRect)) {
        toRemove.add(egg);
        eggsCatched++;
      }
    });
    eggs.removeWhere((egg) => toRemove.contains(egg));
  }

  void eggBreaker() {
    var toRemove = [];
    eggs.forEach((egg) {
      if (egg.eggRect.overlaps(ground)) {
        toRemove.add(egg);
        eggsMissed--;
      }
    });
    eggs.removeWhere((egg) => toRemove.contains(egg));
  }
}
