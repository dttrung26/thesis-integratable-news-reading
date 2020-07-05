
import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import '../common/constants.dart';

class CustomPageScreen extends StatefulWidget {
  final String url;
  final String title;
  final String background;

  CustomPageScreen({this.url, this.background, this.title});

  @override
  State<StatefulWidget> createState() {
    return CustomPageScreenState();
  }
}

class CustomPageScreenState extends State<CustomPageScreen> {
  final bannerHigh = 80.0;

  @override
  Widget build(BuildContext context) {
    return WebviewScaffold(
      url: widget.url,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(
          child: kLoadingWidget(context)
      ),
    );
  }
}
