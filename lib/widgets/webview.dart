import 'package:flutter/material.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';

import '../common/constants.dart';

class WebView extends StatefulWidget {
  final String url;
  final String title;

  WebView({Key key, this.title, @required this.url}) : super(key: key);

  @override
  _WebViewState createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
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
        title: Text(widget.title ?? ''),
      ),
      withZoom: true,
      withLocalStorage: true,
      hidden: true,
      initialChild: Container(child: kLoadingWidget(context)),
    );
  }
}
