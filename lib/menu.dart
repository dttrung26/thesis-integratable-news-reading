import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'generated/l10n.dart';
import 'models/blog_news.dart';
import 'models/category.dart';
import 'models/user.dart';

class MenuBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigation;
  final StreamController<String> controllerRouteWeb;

  MenuBar({this.navigation, this.controllerRouteWeb});

  @override
  _MenuBarState createState() => _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {
  @override
  Widget build(BuildContext context) {
    bool loggedIn = Provider.of<UserModel>(context, listen: false).loggedIn;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: <Widget>[
                Image.asset(kLogoImage, height: 38),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.home,
                    size: 20,
                  ),
                  title: Text(S.of(context).home),
                  onTap: () {
                    if (kLayoutWeb) {
                      widget.controllerRouteWeb.sink.add("/home-screen");
                    } else {
                      Navigator.of(context).pushReplacementNamed("/home");
                    }
                  },
                ),
//                if (kLayoutWeb)
//                  ListTile(
//                    leading: const Icon(
//                      Icons.list,
//                      size: 20,
//                    ),
//                    title: Text(S.of(context).category),
//                    onTap: () {
//                      widget.controllerRouteWeb.sink.add("/category");
//                    },
//                  ),
////                if (kLayoutWeb)
//                  ListTile(
//                    leading: const Icon(
//                      Icons.search,
//                      size: 20,
//                    ),
//                    title: Text(S.of(context).search),
//                    onTap: () {
//                      widget.controllerRouteWeb.sink.add("/search");
//                    },
//                  ),
//                ListTile(
//                  leading: const Icon(FontAwesomeIcons.wordpress, size: 20),
//                  title: Text(S.of(context).blog),
//                  onTap: () {
//                    if (kLayoutWeb) {
//                      widget.controllerRouteWeb.sink.add("/blogs");
//                    } else {
//                      Navigator.of(context).pushNamed("/blogs");
//                    }
//                  },
//                ),
//                if (kLayoutWeb)
//                  ListTile(
//                    leading: const Icon(Icons.settings, size: 20),
//                    title: Text(S.of(context).settings),
//                    onTap: () {
//                      if (kLayoutWeb) {
//                        widget.controllerRouteWeb.sink.add("/setting");
//                      } else {
//                        Navigator.of(context).pushNamed("/setting");
//                      }
//                    },
//                  ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, size: 20),
                  title: loggedIn
                      ? Text(S.of(context).logout)
                      : Text(S.of(context).login),
                  onTap: () {
                    loggedIn
                        ? Provider.of<UserModel>(context, listen: false)
                            .logout()
                        : Navigator.pushNamed(context, "/login");
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    S.of(context).byCategory.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  children: showCategories(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List showCategories() {
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    List<Widget> widgets = [];

    if (categories != null) {
      var list = categories.where((item) => item.parent == 0).toList();
      for (var index in list) {
        widgets.add(
          ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 0.0, top: 0),
              child: Text(
                index.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            children: getChildren(categories, index),
          ),
        );
      }
    }
    return widgets;
  }

  List getChildren(List<Category> categories, Category category) {
    List<Widget> list = [];
    var children = categories.where((o) => o.parent == category.id).toList();

    if (children.length == 0) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(category.name),
            padding: const EdgeInsets.only(left: 20),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            BlogNews.showList(
                context: context, cateId: category.id, cateName: category.name);
          },
        ),
      );
    }
    for (var i in children) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(i.name),
            padding: const EdgeInsets.only(left: 20),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            BlogNews.showList(context: context, cateId: i.id, cateName: i.name);
          },
        ),
      );
    }
    return list;
  }
}
