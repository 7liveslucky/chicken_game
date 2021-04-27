import 'dart:math';
import 'dart:ui';

import 'package:dart_git_fetchbylanguage/bullet.dart';
import 'package:dart_git_fetchbylanguage/egg.dart';
import 'package:dart_git_fetchbylanguage/player.dart';
import 'package:dart_git_fetchbylanguage/score.dart';
import 'package:flame/flame.dart';
import 'package:flame/flame_audio.dart';
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
  await Flame.util.fullScreen();
  await Flame.util.setOrientations(
      [DeviceOrientation.landscapeRight, DeviceOrientation.landscapeLeft]);
  Size size = await Flame.util.initialDimensions();
  var game = new ChickenGame(size);
  game.init();
  runApp(game.widget);
  PanGestureRecognizer panreg = PanGestureRecognizer();
  panreg.onUpdate = game.onPanUpdate;
  DoubleTapGestureRecognizer dtreg = DoubleTapGestureRecognizer();
  dtreg.onDoubleTap = game.onDoubleTap;
  // loadSounds();
}

Future<void> loadSounds() async {
  Flame.audio.disableLog();
  await Flame.audio.loadAll([
    'stone_explode.mp3',
    'shoot.mp3',
    'loop.mp3',
    'lay.mp3',
    'crunch.mp3',
  ]);
}

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
    eggsCatched = 0;
    score = Score(this, 10);
    pause = false;
    lost = false;
    await FlameAudio().loopLongAudio('loop.mp3', volume: .4);
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
    if (lost) {
      Rect gameoverRect = Rect.fromLTWH(0, 0, longEdge(), shortEdge());
      canvas.drawRect(gameoverRect, Paint()..color = Colors.black);
      gameOver.renderRect(canvas, bg.inflate(0));
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

  Future<void> shoot() async {
    if (bullets.length != 10) {
      bullets.add(Bullet(this, player.playerRect.center.dx));
      await FlameAudio().play('shoot.mp3');
    }
  }

  void newGame() {
    player.health = 100;
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
    if (score.lives.length == 0) {
      lost = true;
    }

    if (player.health <= 0) {
      score.lives.removeLast();
    }
  }

  Future<void> eggLayer() async {
    Egg egg = Egg(this, rand.nextDouble() * longEdge());
    if (!egg.stone) await FlameAudio().play('lay.mp3', volume: .1);
    eggs.add(egg);
  }

  void eggCatch() {
    var toRemove = [];
    eggs.forEach((egg) async {
      if (egg.eggRect.overlaps(player.playerRect)) {
        toRemove.add(egg);
        if (egg.stone && egg.stoneIndex < 2) {
          player.health -= 15;
        } else if (egg.stone) {
          if (player.health + 40 > 100)
            player.health = 100;
          else {
            player.health += 40;
          }
          await FlameAudio().play('crunch.mp3');
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
      eggs.forEach((egg) async {
        if (bullet.bulletRect.overlaps(egg.eggRect)) {
          bullet.heat = true;
          toRemoveBullets.add(bullet);
          toRemoveEgg.add(egg);

          if (egg.stone) {
            await FlameAudio().play('stone_explode.mp3');
            player.health += 10;
          } else {
            player.health -= 15;
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
          player.health -= 10;
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
