import 'dart:async';

import 'package:flutter/material.dart';

class LayoutWebCustom extends StatelessWidget {
  final Widget menu;
  final Widget content;

  LayoutWebCustom({
    Key key,
    this.menu,
    this.content
  }) :super(key:key);
  static StreamController<bool> _isShowMenu = StreamController<bool>.broadcast();

  dispose(){
    _isShowMenu?.close();
  }
  static changeStateMenu(bool state){
    _isShowMenu.sink.add(state);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 1400),
        child: StreamBuilder<bool>(
          initialData: true,
          stream: _isShowMenu.stream,
          builder: (context, snapshot) {
            return Row(
              children: <Widget>[
                snapshot.data ? Container(
                  width: 250, //  (cappedTextScale(context) - 1)
                  alignment: Alignment.topCenter,
                  padding: const EdgeInsets.only(bottom: 32),
                  child: menu,
                  color: Theme.of(context).primaryColorLight.withOpacity(0.7),
                ) : SizedBox(),
                SizedBox(width: 10),
                Expanded(child: content)
              ]
            );
          }
        )
      )
    );
  }
}