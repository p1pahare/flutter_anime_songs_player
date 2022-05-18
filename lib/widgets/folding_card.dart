import 'dart:math' as math;

import 'package:flutter/material.dart';

/// It helps you in creating a Romantic Folding Card.
/// This widget is created to be able to standalone with any views, helps you able to add it into any complex design.
class FoldingCard extends StatefulWidget {
  final Widget expandedCard;
  final double expandedHeight;
  final double foldingHeight;
  final Widget cover;
  final Widget? coverBackground;
  final bool foldOut;
  final Function(double value, AnimationStatus status)? listener;
  final Curve curve;
  final Duration duration;
  final BoxDecoration? foldingShadow;
  final bool foldingShadowVisible;

  /// Create a Romantic Folding Card.
  ///
  /// This widget will base on [foldOut] to decide to run the folding animation. The final widget after folded out is a [Column] includes [expandedCard] and [cover].
  ///
  /// The [expandedCard] is fixed by [expandedHeight], and the [cover] & [coverBackground] is fixed by [foldingHeight].
  ///
  /// [expandedHeight] & [foldingHeight] it's used to calculate the [_FoldingCardState._foldingCount].
  ///
  /// [foldingHeight] is height of each folding parts.
  ///
  /// During animating, when the [cover] is folding at 50% each of cycles, it will be turned into the [coverBackground].
  /// And it has a [foldingShadow] that placed backward of [coverBackground] and [cover].
  /// There is a default [foldingShadow], you can custom it also if you don't want to show it, set [foldingShadowVisible] to false, default is true.
  ///
  /// You can also custom the overall animation by using [curve] & [duration].
  const FoldingCard({
    Key? key,
    this.foldOut = false,
    this.listener,
    this.curve = Curves.linear,
    this.duration = const Duration(milliseconds: 1200),
    required this.cover,
    this.coverBackground,
    required this.expandedCard,
    required this.expandedHeight,
    required this.foldingHeight,
    this.foldingShadow,
    this.foldingShadowVisible = true,
  })  : assert(expandedHeight ~/ foldingHeight >= 1),
        super(key: key);

  @override
  _FoldingCardState createState() => _FoldingCardState();
}

class _FoldingCardState extends State<FoldingCard>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final AnimationController _controllerShadow;

  late TweenSequence<Alignment> _coverAlignmentTween;
  late TweenSequence<Offset> _coverTranslateTween;
  late int _foldingCount;
  late TweenSequence<double> _shadowOpacityTween;
  late TweenSequence<double> _foldingOutBottomMarginTween;
  late TweenSequence<double> _foldingInTopMarginTween;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: widget.duration, value: 1.0);
    _controller.addListener(() {
      if (widget.listener != null) {
        widget.listener!(_controller.value, _controller.status);
      }
      setState(() {});
    });
    _controllerShadow =
        AnimationController(vsync: this, duration: widget.duration);
    _controllerShadow.addListener(() {
      setState(() {});
    });
    _initTweens();
    super.initState();
  }

  void _initTweens() {
    _foldingCount = (widget.expandedHeight / widget.foldingHeight).round();
    if (_foldingCount * widget.foldingHeight > widget.expandedHeight) {
      _foldingCount--;
    } else if (_foldingCount * widget.foldingHeight < widget.expandedHeight) {
      _foldingCount++;
    }
    _coverAlignmentTween = TweenSequence(List.generate(_foldingCount, (index) {
      var a = index % 2 == 0 ? Alignment.bottomCenter : Alignment.topCenter;
      return TweenSequenceItem(
        tween: Tween(begin: a, end: a),
        weight: _weightPerPage,
      );
    }));
    _coverTranslateTween = TweenSequence(List.generate(
      _foldingCount,
      (index) {
        var y = index ~/ 2 * (-widget.foldingHeight * 2);
        return TweenSequenceItem(
          tween: Tween(begin: Offset(0, y), end: Offset(0, y)),
          weight: _weightPerPage,
        );
      },
    ));
    _shadowOpacityTween = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 0.1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 0.8,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 0.1,
      ),
    ]);
    _foldingOutBottomMarginTween = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: widget.foldingHeight),
        weight: 0.2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.foldingHeight, end: widget.foldingHeight),
        weight: 0.7,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.foldingHeight, end: 0.0),
        weight: 0.1,
      ),
    ]);
    _foldingInTopMarginTween = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: widget.foldingHeight, end: 0.0),
        weight: _weightPerPage / 2,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: widget.foldingHeight),
        weight: 1 - _weightPerPage,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.foldingHeight, end: 0.0),
        weight: _weightPerPage / 2,
      ),
    ]);
  }

  double get _weightPerPage => 1.0 / _foldingCount;

  @override
  void dispose() {
    _controller.dispose();
    _controllerShadow.dispose();
    super.dispose();
  }

  /// This logic is used to update exactly the current animation state. If not, there will be caused a bug if this [FoldingCard] is placed in a [ListView].
  @override
  void didChangeDependencies() {
    _controllerShadow.value = 0;
    if (widget.foldOut) {
      _controller.value = 0;
    } else {
      _controller.value = 1;
    }
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant FoldingCard oldWidget) {
    _initTweens();

    if (oldWidget.foldOut != widget.foldOut) {
      if (widget.foldOut) {
        _controllerShadow.forward(from: 0);
        if (_controller.value > 0) _controller.reverse(from: 1);
      } else {
        _controllerShadow.reverse(from: 1.0);
        if (_controller.value < 1) _controller.forward(from: 0);
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    var foldingInValue =
        widget.curve.transform(_controller.value).clamp(0.0, 1.0);
    var needBackground = foldingInValue >= _weightPerPage / 2;
    var deltaYWithTrueExpandedHeight = widget.expandedHeight +
        widget.foldingHeight -
        (_foldingCount + 1) * widget.foldingHeight;
    var expandedHeightFactor = math.max(
        widget.foldingHeight / widget.expandedHeight,
        ((1.0 - foldingInValue) * 1.22).clamp(0.0, 1.0));
    var foldingOutValue = 1 - foldingInValue;
    var coverTranslateY = widget.foldingHeight * (_foldingCount - 1) +
        deltaYWithTrueExpandedHeight;
    var foldingRotateRad = foldingInValue * -math.pi * _foldingCount;
    var coverFoldingRotateRad = _foldingCount % 2 != 0 ? math.pi : 0.0;

    return Padding(
      padding: EdgeInsets.only(
        bottom: _foldingOutBottomMarginTween.transform(foldingOutValue),
      ),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Column(
            children: [
              ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: expandedHeightFactor,
                  child: SizedBox(
                    height: widget.expandedHeight,
                    child: widget.expandedCard,
                  ),
                ),
              ),
              Stack(
                children: [
                  SizedBox(
                    height: _foldingInTopMarginTween.transform(foldingInValue),
                  ),
                  if (widget.foldingShadowVisible)
                    Opacity(
                      opacity: _shadowOpacityTween.transform((foldingOutValue)),
                      child: Container(
                        foregroundDecoration: widget.foldingShadow ??
                            BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: widget.foldingHeight,
                                  spreadRadius: widget.foldingHeight * 0.5,
                                ),
                              ],
                            ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Transform(
            transform: Matrix4.identity()..translate(0.0, coverTranslateY),
            child: Transform(
              transform: Matrix4.identity()
                ..translate(
                    0.0,
                    _coverTranslateTween.transform(foldingInValue).dy -
                        (needBackground ? deltaYWithTrueExpandedHeight : 0)),
              child: Transform(
                alignment: _coverAlignmentTween.transform(foldingInValue),
                transform: Matrix4.identity() //
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(foldingRotateRad),
                child: Transform(
                  alignment: _coverAlignmentTween.transform(foldingInValue),
                  transform: Matrix4.identity() //
                    ..rotateX(math.pi),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity() //
                      ..rotateX(math.pi),
                    child: Stack(
                      children: [
                        SizedBox(
                          child: widget.cover,
                          width: double.infinity,
                          height: widget.foldingHeight,
                        ),
                        if (needBackground && widget.coverBackground != null)
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity() //
                              ..rotateX(coverFoldingRotateRad),
                            child: SizedBox(
                              child: widget.coverBackground!,
                              width: double.infinity,
                              height: widget.foldingHeight,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
