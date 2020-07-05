import 'package:flutter/material.dart';

import '../../common/constants.dart';

class Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      //margin: EdgeInsets.only(left: 15, right:15),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 55,
            left: 10,
            child: IconButton(
              icon: Icon(
                Icons.blur_on,
                color: Theme.of(context).accentColor.withOpacity(0.6),
                size: 22,
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          Center(
            child: Padding(
              child: Image.asset(kLogoImage, height: 40),
              padding: EdgeInsets.only(bottom: 10.0, top: 60.0),
            ),
          ),
        ],
      ),
    );
  }
}
