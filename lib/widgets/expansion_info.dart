import 'package:flutter/material.dart';
import 'package:configurable_expansion_tile/configurable_expansion_tile.dart';

class ExpansionInfo extends StatelessWidget {
  final String title;
  final bool expand;
  final List<Widget> children;

  ExpansionInfo({@required this.title, @required this.children, this.expand = false});

  @override
  Widget build(BuildContext context) {
    return ConfigurableExpansionTile(
      initiallyExpanded: expand,
      headerExpanded: Flexible(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Text(title, style: TextStyle( fontSize: 20, fontWeight: FontWeight.w600)),
              Icon(
                Icons.keyboard_arrow_up,
                color: Theme.of(context).accentColor,
                size: 20,
              )
            ])),
      ),
      header: Flexible(
        child: Padding(
            padding: EdgeInsets.symmetric(vertical: 17.0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
              Text(title, style: TextStyle( fontSize: 20, fontWeight: FontWeight.w600)),
              Icon(
                Icons.keyboard_arrow_right,
                color: Theme.of(context).accentColor,
                size: 20,
              )
            ])),
      ),
      children: children,
    );
  }
}
