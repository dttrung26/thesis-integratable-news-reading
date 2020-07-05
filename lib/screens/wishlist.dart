import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/styles.dart';
import '../common/tools.dart';
import '../generated/l10n.dart';
import '../models/blog_news.dart';
import '../models/wishlist.dart';
import '../widgets/blog/detailed_blog/blog_view.dart';

class WishList extends StatefulWidget {
  final bool canBack;

  WishList({this.canBack = false});

  @override
  State<StatefulWidget> createState() {
    return WishListState();
  }
}

class WishListState extends State<WishList>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (widget.canBack)
              SafeArea(
                child: FlatButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.arrow_back_ios),
                    label: Container()),
              ),
            Expanded(
              child: ListenableProvider.value(
                  value: Provider.of<WishListModel>(context, listen: false),
                  child:
                      Consumer<WishListModel>(builder: (context, model, child) {
                    if (model.blogs.isEmpty) {
                      return EmptyWishlist();
                    } else {
                      return SafeArea(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: <Widget>[
                                    Text(S.of(context).myWishList,
                                        style: TextStyle(
                                            fontSize: 28,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                padding: EdgeInsets.only(top: 10, left: 15),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 15),
                                child: Text(
                                    "${model.blogs.length} " +
                                        S.of(context).items,
                                    style: TextStyle(
                                        fontSize: 14, color: kGrey400)),
                              ),
                              Divider(height: 1, color: kGrey200),
                              SizedBox(height: 15),
                              Expanded(
                                child: ListView.builder(
                                    itemCount: model.blogs.length,
                                    itemBuilder: (context, index) {
                                      return WishlistItem(
                                        blog: model.blogs[index],
                                        onRemove: () {
                                          Provider.of<WishListModel>(context,
                                                  listen: false)
                                              .removeToWishlist(
                                                  model.blogs[index]);
                                        },
                                      );
                                    }),
                              )
                            ]),
                      );
                    }
                  })),
            )
          ],
        ),
      ),
    ]);
  }
}

class EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          SizedBox(height: 80),
          Image.asset(
            'assets/images/empty_wishlist.png',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 20),
          Text(S.of(context).noFavoritesYet,
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center),
          SizedBox(height: 15),
          Text(S.of(context).emptyWishlistSubtitle,
              style: TextStyle(fontSize: 14, color: kGrey900),
              textAlign: TextAlign.center),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                      child: Text(S.of(context).startExploring.toUpperCase()),
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.pushNamed(context, "/home");
                      }),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 44,
                  child: RaisedButton(
                      child: Text(S.of(context).searchForItems.toUpperCase()),
                      color: kGrey200,
                      textColor: kGrey400,
                      onPressed: () {
                        Navigator.of(context).pushNamed("/search");
                      }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  WishlistItem({@required this.blog, this.onRemove});

  final BlogNews blog;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final localTheme = Theme.of(context);

    return Column(children: [
      Row(
        key: ValueKey(blog.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: onRemove,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      print('item id: ${blog.id}');
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              getDetailBlog(blog),
                        ),
                      );
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: screenSize.width * 0.25,
                          height: screenSize.width * 0.15,
                          child: Tools.image(
                              fit: BoxFit.fitWidth,
                              url: blog.imageFeature,
                              size: kSize.medium),
                        ),
                        SizedBox(width: 16.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                blog.title,
                                style: localTheme.textTheme.caption,
                              ),
                              SizedBox(height: 7),
                              Text(Tools.formatDateString(blog.date),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline5
                                      .copyWith(color: kGrey400, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      SizedBox(height: 10.0),
      Divider(color: kGrey200, height: 1),
      SizedBox(height: 10.0),
    ]);
  }
}
