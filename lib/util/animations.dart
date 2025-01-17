import 'dart:math';
import 'package:flutter/material.dart';

class RunningAnimation extends StatefulWidget {
  const RunningAnimation({super.key});

  @override
  RunningAnimationState createState() => RunningAnimationState();
}

class RunningAnimationState extends State<RunningAnimation>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    Tween<double> rotationTween = Tween(begin: -pi, end: pi);

    animation = rotationTween.animate(controller)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.repeat();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });

    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, snapshot) {
        return CustomPaint(
          painter: ShapePainter(animation.value),
          child: Container(),
        );
      },
    );
  }
}

class ShapePainter extends CustomPainter {
  final double radians;
  ShapePainter(this.radians);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = const Color.fromRGBO(88, 200, 223, 1)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    Rect myRect = Rect.fromLTWH(0.0, 0.0, size.width, size.height);
    canvas.drawArc(myRect, radians, 3 * pi / 2, false, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

/////////

class IdleAnimation extends StatefulWidget {
  const IdleAnimation({super.key});

  @override
  IdleAnimationState createState() => IdleAnimationState();
}

class IdleAnimationState extends State<IdleAnimation>
    with TickerProviderStateMixin {
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 15.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
                color: const Color.fromRGBO(88, 200, 223, 1),
                blurRadius: _animation.value,
                spreadRadius: _animation.value)
          ]),
    );
  }
}
