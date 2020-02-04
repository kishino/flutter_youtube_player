import 'package:disposable_provider/disposable_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_youtube_player/theme.dart';

// TODO(mono): 完全に隠れた方のアニメーションを無効化したり(Visibility+α)
class PlayerNotifier implements Disposable {
  PlayerNotifier({
    @required this.themeNotifier,
    @required this.tickerProvider,
  }) {
    _expandingAnimationController = AnimationController(
      vsync: tickerProvider,
      duration: duration,
    )..addListener(() {
        themeNotifier.appBarBrightness =
            _topFadeAnimation.value == 0 ? Brightness.light : Brightness.dark;
      });
    _expandingAnimation = _expandingAnimationController;
    _topFadeAnimation = _expandingAnimationController.drive(
      CurveTween(
        curve: const Interval(0.8, 1),
      ),
    );
    _contentFadeAnimation = _expandingAnimationController.drive(
      CurveTween(
        curve: const Interval(0.2, 1),
      ),
    );
  }

  static const duration = Duration(milliseconds: 1000);
  final ThemeNotifier themeNotifier;
  final TickerProvider tickerProvider;
  AnimationController _expandingAnimationController;
  Animation<double> _expandingAnimation;
  Animation<double> _topFadeAnimation;
  Animation<double> _contentFadeAnimation;

  Animation<double> get expandingAnimation => _expandingAnimation;
  Animation<double> get topFadeAnimation => _topFadeAnimation;
  Animation<double> get contentFadeAnimation => _contentFadeAnimation;

  var _status = PlayerStatus.shrinked;
  PlayerStatus get status => _status;

  void _resetAnimationIfNeeded() {
    if (_expandingAnimation != _expandingAnimationController) {
      _expandingAnimation = _expandingAnimationController;
    }
  }

  void addExpandingAnimation(double value) {
    _resetAnimationIfNeeded();
    _expandingAnimationController.value += value;
  }

  Future<void> shrink() async {
    _status = PlayerStatus.shrinked;
    _expandingAnimation = _expandingAnimationController
        .drive(
          CurveTween(
            curve: Interval(
              0,
              _expandingAnimationController.value,
              curve: Curves.easeInCirc,
            ),
          ),
        )
        .drive(
          Tween<double>(
            begin: 0,
            end: _expandingAnimationController.value,
          ),
        );
    await _expandingAnimationController.reverse();
    _resetAnimationIfNeeded();
  }

  Future<void> expand() async {
    _status = PlayerStatus.expanded;
    _expandingAnimation = _expandingAnimationController
        .drive(
          CurveTween(
            curve: Interval(
              _expandingAnimationController.value,
              1,
              curve: Curves.easeOutExpo,
            ),
          ),
        )
        .drive(
          Tween<double>(
            begin: _expandingAnimationController.value,
            end: 1,
          ),
        );
    await _expandingAnimationController.forward();
    _resetAnimationIfNeeded();
  }

  @override
  void dispose() {
    _expandingAnimationController.dispose();
  }
}

enum PlayerStatus {
  shrinked,
  expanded,
}
