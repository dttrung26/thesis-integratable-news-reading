import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../../../common/tools.dart';

class HeaderType extends StatelessWidget {
  final config;

  HeaderType({this.config});

  @override
  Widget build(BuildContext context) {
    List<String> _rotate = [];
    double _fontSize = Tools.formatDouble(config['fontSize'] ?? 20);

    if (config["rotate"] != null)
      for (var name in config["rotate"]) {
        _rotate.add('$name');
      }

    switch (config['type']) {
      case 'rotate':
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              config['title'],
              style: TextStyle(fontSize: _fontSize),
            ),
            SizedBox(width: 10.0, height: 20.0),
            RotateAnimatedTextKit(
              text: _rotate,
              transitionHeight: 40.0,
              textStyle: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );
      case 'fade':
        return SizedBox(
          width: 250.0,
          child: FadeAnimatedTextKit(
            text: _rotate,
            textStyle: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.bold),
          ),
        );
      case 'typer':
        return SizedBox(
          width: 250.0,
          child: TyperAnimatedTextKit(
            text: _rotate,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
        );
      case 'typewriter':
        return SizedBox(
          width: 250.0,
          child: TypewriterAnimatedTextKit(
            text: _rotate,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
        );
      case 'scale':
        return SizedBox(
          width: 250.0,
          child: ScaleAnimatedTextKit(
            text: _rotate,
            textStyle: TextStyle(fontSize: _fontSize),
          ),
        );
      case 'color':
        return SizedBox(
          width: 250.0,
          height: 40,
          child: ColorizeAnimatedTextKit(
            onTap: () {
              print("Tap Event");
            },
            text: _rotate,
            textStyle: TextStyle(fontSize: _fontSize),
            colors: [
              Colors.purple,
              Colors.blue,
              Colors.yellow,
              Colors.red,
            ],
          ),
        );
      case 'static':
      default:
        return AutoSizeText(
          config['title'] ?? "",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: _fontSize ?? 30,
          ),
          maxLines: 2,
          minFontSize: _fontSize - 10,
          maxFontSize: _fontSize,
          group: AutoSizeGroup(),
        );
    }
  }
}
