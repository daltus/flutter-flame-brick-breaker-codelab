import 'package:brick_breaker/src/components/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class Ball extends CircleComponent with CollisionCallbacks, HasGameReference<BrickBreaker> {
  Ball({
    required this.velocity,
    required super.position,
    required double radius,
    required this.difficultyModifier,
  }) : super(
    radius: radius,
    anchor: Anchor.center,
    paint: Paint()
      ..color = const Color(0xff1e6091)
      ..style = PaintingStyle.fill,
    children: [CircleHitbox()],
  );

  final double difficultyModifier;
  final Vector2 velocity;

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is PlayArea) {
      if (intersectionPoints.first.y <= 0) {
        velocity.y = -velocity.y;
      } else if (intersectionPoints.first.x <= 0) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.x >= game.width) {
        velocity.x = -velocity.x;
      } else if (intersectionPoints.first.y >= game.height) {
        add(RemoveEffect(
          delay: 0.35,
          onComplete: () {
            game.playState = PlayState.gameOver;
          },
        ));
      } else {
        debugPrint('unhandled collision for Ball with PlayArea: $intersectionPoints');
      }
    } else if (other is Bat) {
      Bat bat = other;
      velocity.y = -velocity.y;
      velocity.x =
        velocity.x
        + (position.x - bat.position.x) / bat.size.x * game.width * 0.3;
    } else if (other is Brick) {
      Brick brick = other;
      if (position.y < brick.position.y - brick.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.y > brick.position.y + brick.size.y / 2) {
        velocity.y = -velocity.y;
      } else if (position.x < brick.position.x) {
        velocity.x = -velocity.x;
      } else if (position.x > brick.position.x) {
        velocity.x = -velocity.x;
      }
      velocity.setFrom(velocity * difficultyModifier);
    } else {
      debugPrint('unhandled collision for Ball with $other');
    }
  }
}