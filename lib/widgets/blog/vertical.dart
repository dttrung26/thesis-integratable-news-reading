import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/app.dart';
//import '../../models/product.dart';
import '../../models/blog_news.dart';
import 'header/header_view.dart';
import 'vertical/menu_layout.dart';
import 'vertical/pinterest_layout.dart';
import 'vertical/vertical_layout.dart';

class VerticalLayout extends StatefulWidget {
  final config;

  VerticalLayout({this.config});

  @override
  _VerticalLayoutState createState() => _VerticalLayoutState();
}

class _VerticalLayoutState extends State<VerticalLayout> {
  Widget renderLayout() {
    switch (widget.config['layout']) {
      case 'menu':
        return MenuLayout(config: widget.config);
      case 'pinterest':
        return PinterestLayout(config: widget.config);
      default:
        return VerticalViewLayout(config: widget.config);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppModel>(context, listen: false).locale;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        if (widget.config["name"] != null)
          HeaderView(
            headerText: widget.config["name"] ?? '',
            showSeeAll: true,
            callback: () => BlogNews.showList(
              context: context,
              config: widget.config,
            ),
          ),
        renderLayout()
      ],
    );
  }
}
