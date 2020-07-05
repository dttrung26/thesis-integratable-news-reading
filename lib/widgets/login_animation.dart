import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class StaggerAnimation extends StatelessWidget {
  final VoidCallback onTap;
  final String titleButton;

  StaggerAnimation(
      {Key key,
      this.buttonController,
      this.onTap,
      this.titleButton = "Sign In"})
      : buttonSqueezeanimation = new Tween(
          begin: 320.0,
          end: 50.0,
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.0,
              0.150,
            ),
          ),
        ),
        containerCircleAnimation = new EdgeInsetsTween(
          begin: const EdgeInsets.only(bottom: 30.0),
          end: const EdgeInsets.only(bottom: 0.0),
        ).animate(
          new CurvedAnimation(
            parent: buttonController,
            curve: new Interval(
              0.500,
              0.800,
              curve: Curves.ease,
            ),
          ),
        ),
        super(key: key);

  final AnimationController buttonController;
  final Animation<EdgeInsets> containerCircleAnimation;
  final Animation buttonSqueezeanimation;

  Widget _buildAnimation(BuildContext context, Widget child) {
    return new GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
          width: buttonSqueezeanimation.value,
          height: 50,
          alignment: FractionalOffset.center,
          decoration: new BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.all(const Radius.circular(25.0)),
          ),
          child: buttonSqueezeanimation.value > 75.0
              ? new Text(
                  S.of(context).signInWithEmail,
                  style: new TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.3,
                  ),
                )
              : CircularProgressIndicator(
                  value: null,
                  strokeWidth: 1.0,
                  valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
                )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return new AnimatedBuilder(
      builder: _buildAnimation,
      animation: buttonController,
    );
  }
}
