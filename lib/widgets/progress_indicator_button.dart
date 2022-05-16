import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class ProgressIndicatorButton extends StatefulWidget {
  const ProgressIndicatorButton({Key? key}) : super(key: key);

  @override
  _ProgressIndicatorButtonState createState() =>
      _ProgressIndicatorButtonState();
}

class _ProgressIndicatorButtonState extends State<ProgressIndicatorButton>
    with SingleTickerProviderStateMixin {
  final double initialRadius = 20.0;
  double radius = 20.0;
  double pi = 3.14;
  late final AnimationController _animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))
        ..repeat();

  List<Color> colors = [Colors.pink, Colors.blue, Colors.green];
  Color colorNow = Colors.pink;
  int colorIndex = 0;
  void changeColor() {
    if (colorIndex < 2) {
      colorIndex = colorIndex + 1;
      setState(() {
        colorNow = colors[colorIndex];
      });
    } else {
      colorIndex = 0;
      setState(() {
        colorNow = colors[colorIndex];
      });
    }
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => changeColor());
  }

  @override
  void dispose() {
    timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (BuildContext context, Widget? child) {
        return Transform.rotate(
          angle: _animationController.value * 2 * pi,
          child: SizedBox(
            width: 100.0,
            height: 100.0,
            child: Stack(
              children: [
                const Dot(
                  radius: 30.0,
                  color: Colors.transparent,
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(pi / 4),
                    radius * sin(pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(2 * pi / 4),
                    radius * sin(2 * pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(3 * pi / 4),
                    radius * sin(3 * pi / 4),
                  ),
                  child: Dot(
                    radius: 10.0,
                    color: colorNow,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(4 * pi / 4),
                    radius * sin(4 * pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(5 * pi / 4),
                    radius * sin(5 * pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(6 * pi / 4),
                    radius * sin(6 * pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(7 * pi / 4),
                    radius * sin(7 * pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
                Transform.translate(
                  offset: Offset(
                    radius * cos(8 * pi / 4),
                    radius * sin(8 * pi / 4),
                  ),
                  child: const Dot(
                    radius: 10.0,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Dot extends StatelessWidget {
  final double? radius;
  final Color color;
  const Dot({Key? key, this.radius, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: radius,
        height: radius,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
