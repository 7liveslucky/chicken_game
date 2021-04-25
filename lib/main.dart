import 'dart:math';
import 'dart:ui';

import 'package:dart_git_fetchbylanguage/bullet.dart';
import 'package:dart_git_fetchbylanguage/egg.dart';
import 'package:dart_git_fetchbylanguage/player.dart';
import 'package:dart_git_fetchbylanguage/score.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/keyboard.dart';
import 'package:flame/sprite.dart';
import 'package:flame/util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'eggGenerator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.util.setLandscapeLeftOnly();
  await Flame.util.fullScreen();
  Size size = await Flame.util.initialDimensions();
  var game = new ChickenGame(size);
  game.init();
  runApp(game.widget);
  PanGestureRecognizer panreg = PanGestureRecognizer();
  panreg.onUpdate = game.onPanUpdate;
  DoubleTapGestureRecognizer dtreg = DoubleTapGestureRecognizer();
  dtreg.onDoubleTap = game.onDoubleTap;
}

// Future<void> loadSounds() async {
//   Flame.audio.disableLog();
//   await Flame.audio.loadAll([
//     'stone_explode.mp3',
//     'shoot.mp3',
//     'loop.mp3',
//     'lay.mp3',
//     'crunch.mp3',
//   ]);
// }

class ChickenGame extends Game
    with PanDetector, DoubleTapDetector, KeyboardEvents {
  Size size;
  double widthFactor;
  double heightFactor;
  Player player;
  List<Egg> eggs;
  List<Bullet> bullets;
  EggsGenerator eggsGenerator;

  Random rand;
  Rect ground;
  Rect bg;
  Rect pauseBtn;
  int eggsCatched;
  int eggsMissed;
  Score score;
  Sprite groundSprite = Sprite('ground.png');
  Sprite bgSprite = Sprite('background.png');
  Sprite gameOver = Sprite('game-over.png');
  Sprite pauseSprite = Sprite('pause.png');

  var flameUtil = Util();
  bool pause;
  bool lost;

  Future<void> init() async {
    rand = Random();
    widthFactor = longEdge() / 10;
    heightFactor = shortEdge() / 10;
    player = Player(this);
    eggs = [];
    bullets = [];
    eggsGenerator = EggsGenerator(this);
    eggsMissed = 0;
    eggsCatched = 0;
    score = Score(this, 10);
    pause = false;
    lost = false;
  }

  @override
  void render(Canvas canvas) {
    if (size == null) {
      return;
    }

    bg = Rect.fromLTWH(0, 0, longEdge(), shortEdge() - heightFactor * 0.8);

    if (1 == 1) {
      //!player.lost
      canvas.drawRect(bg, Paint()..color = Color(0x00000000));
    } else {
      canvas.drawRect(bg, Paint()..color = Colors.red);
      gameOver.renderRect(canvas, bg.inflate(0));
      return;
    }

    ground =
        Rect.fromLTWH(0, shortEdge() - heightFactor, longEdge(), heightFactor);
    canvas.drawRect(ground, Paint()..color = Color(0x00000000));
    bgSprite.renderRect(canvas, bg.inflate(0));
    groundSprite.renderRect(canvas, ground.inflate(0));
    player.render(canvas);
    eggs.forEach((egg) => egg.render(canvas));
    score.render(canvas);
    bullets.forEach((bullet) => bullet.render(canvas));
    if (player.health <= 0 || eggsMissed >= score.maxLives) {
      Rect gameoverRect = Rect.fromLTWH(0, 0, longEdge(), shortEdge());
      canvas.drawRect(gameoverRect, Paint()..color = Colors.black);
      gameOver.renderRect(canvas, bg.inflate(0));
      lost = true;
    }
    if (pause) {
      canvas.drawRect(Rect.largest, Paint()..color = Colors.white70);
      pauseBtn = Rect.fromLTWH(
          longEdge() / 2 - widthFactor * 1.2,
          shortEdge() / 2 - heightFactor * 1.2,
          widthFactor * 2.4,
          heightFactor * 2.4);
      canvas.drawRect(pauseBtn, Paint()..color = Color(0x00000000));
      pauseSprite.renderRect(canvas, pauseBtn.inflate(0));
    }
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    if (pause) return;
    final delta = details.delta;
    final double pr = player.playerRect.right;
    final double pl = player.playerRect.left;
    double xMove = delta.dx;
    if (pr + delta.dx >= longEdge()) {
      xMove = longEdge() - pr;
    } else if (pl + delta.dx <= 0) {
      xMove = -pl;
    }
    player.playerRect = player.playerRect.translate(xMove, 0);
    if (pr + delta.dx > pr) {
      player.l = true;
    } else {
      player.l = false;
    }
    if (delta.dy >= heightFactor) {
      pauseGame();
    }
  }

  void pauseGame() {
    if (pause == false) {
      pause = true;
    } else {
      pause = false;
    }
  }

  @override
  void onDoubleTap() {
    if (pause) {
      pause = false;
    }
    if (lost) {
      newGame();
      return;
    }
    shoot();
  }

  void shoot() {
    if (bullets.length != 10) {
      bullets.add(Bullet(this, player.playerRect.center.dx));
    }
  }

  void newGame() {
    player.health = 100;
    eggsMissed = 0;
    eggsCatched = 0;
    eggs = [];
    lost = false;
    score = Score(this, 10);
    pause = false;
  }

  @override
  void update(double t) {
    if (!pause) {
      eggsGenerator.update(t);
      eggs.forEach((egg) => egg.update(t));
      bullets.forEach((bullet) => bullet.update(t));
      score.update(t);
    }
  }

  void eggLayer() {
    eggs.add(Egg(this, rand.nextDouble() * longEdge()));
  }

  void eggCatch() {
    var toRemove = [];
    eggs.forEach((egg) {
      if (egg.eggRect.overlaps(player.playerRect)) {
        toRemove.add(egg);
        if (egg.stone && egg.stoneIndex < 2) {
          player.health -= 15;
        } else if (egg.stone) {
          player.health += 10;
        } else {
          eggsCatched++;
        }
      }
    });
    eggs.removeWhere((egg) => toRemove.contains(egg));
  }

  void bulletEffect() {
    var toRemoveEgg = [];
    var toRemoveBullets = [];
    bullets.forEach((bullet) {
      eggs.forEach((egg) {
        if (bullet.bulletRect.overlaps(egg.eggRect)) {
          bullet.heat = true;
          toRemoveBullets.add(bullet);
          toRemoveEgg.add(egg);

          if (egg.stone) {
            player.health += 2;
          } else {
            player.health -= 2;
          }
        }
      });
      if (bullet.bulletRect.top <= 0.0) {
        toRemoveBullets.add(bullet);
      }
    });

    eggs.removeWhere((egg) => toRemoveEgg.contains(egg));
    Future.delayed(const Duration(milliseconds: 100), () {
      bullets.removeWhere((bullet) => toRemoveBullets.contains(bullet));
    });
  }

  void eggBreaker() {
    var toRemove = [];
    eggs.forEach((egg) {
      if (!egg.eggRect.overlaps(bg)) {
        toRemove.add(egg);
        if (!(egg.stone && egg.stoneIndex <= 2)) {
          eggsMissed++;
        }
      }
    });
    eggs.removeWhere((egg) => toRemove.contains(egg));
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (lost) {
      if (event.isShiftPressed) {
        newGame();
      }
    }
    if (event.data.keyLabel == " " ||
        event.data.keyLabel == "ArrowUp" ||
        event.data.keyLabel == "w") {
      shoot();
    }
    if (event.data.keyLabel == "d" || event.data.keyLabel == "ArrowRight") {
      double pr = player.playerRect.right;
      double xMove = widthFactor / 8;
      if (pr + xMove <= longEdge()) {
        player.l = true;
        player.playerRect = player.playerRect.translate(xMove, 0);
      }
    }
    if (event.data.keyLabel == "a" || event.data.keyLabel == "ArrowLeft") {
      double pl = player.playerRect.left;
      double xMove = widthFactor / 8;
      if (pl + xMove >= 0) {
        player.l = false;
        player.playerRect = player.playerRect.translate((-1) * xMove, 0);
      }
    }

    if (event.isAltPressed) {
      pauseGame();
    }
  }

  ChickenGame(this.size);

  double shortEdge() {
    if (size.height > size.width) {
      return size.width;
    }
    return size.height;
  }

  double longEdge() {
    if (size.height > size.width) {
      return size.height;
    }
    return size.width;
  }
}
