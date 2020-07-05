import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '../common/config.dart';
class ShareButton extends StatelessWidget {
  final String blogSlug;
  ShareButton({this.blogSlug});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GestureDetector(
        onTap: () {
          Share.share(
              'Take a look at this news at ${serverConfig['url']}/$blogSlug');
        },
        child: Container(
          margin: EdgeInsets.all(12.0),
          padding: EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Icon(
            Icons.share,
            size: 18.0,
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
