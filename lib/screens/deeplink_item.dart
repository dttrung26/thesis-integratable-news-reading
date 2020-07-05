import 'package:flutter/material.dart';
import '../services/wordpress.dart';
import './../models/blog_news.dart';
import '../widgets/blog/detailed_blog/blog_view.dart';

class ItemDeepLink extends StatefulWidget {
  final int itemId;

  ItemDeepLink({this.itemId});

  @override
  _ItemDeepLinkState createState() => _ItemDeepLinkState();
}

class _ItemDeepLinkState extends State<ItemDeepLink> {
  final WordPress _service = WordPress();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BlogNews>(
      future: _service.getBlog(widget.itemId),
      builder: (BuildContext context, AsyncSnapshot<BlogNews> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Scaffold(
              body: Container(
                color: Colors.white,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError || snapshot.data.id == null) {

              return Material(
                child: Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Opps, this blog seems no longer exist',
                        style: TextStyle(color: Colors.black),
                      ),
                      FlatButton(
                        color: Theme.of(context).accentColor,
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: new Text(
                          "Go back to home page",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            print('snapshot.dataaa ${snapshot.data}');
            return getDetailBlog(snapshot.data);
        }
      },
    );
  }
}
