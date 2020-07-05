import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/tools.dart';
import '../../models/app.dart';
import 'header/header_view.dart';
import '../../common/config.dart';
import '../../models/blog_news.dart';
import '../../screens/blogs.dart';

class HorizontalListItems extends StatefulWidget {
  final config;
  HorizontalListItems({this.config});
  @override
  _HorizontalListItemsState createState() => _HorizontalListItemsState();
}

class _HorizontalListItemsState extends State<HorizontalListItems> {
  Future<List<BlogNews>> _fetchBlogs;

  @override
  void initState() {
    _fetchBlogs = getBlogs(); // only create the future once.
    super.initState();
  }

  Future<List<BlogNews>> getBlogs() async {
    List<BlogNews> blogs = [];
    var _jsons = await BlogNews.getBlogs(url: serverConfig['blog'], page: 1);
//    Provider.of<AppModel>(context).appConfig

    for (var item in _jsons) {
      blogs.add(BlogNews.fromJson(item));
    }
    return blogs;
  }


  Widget _buildHeader(context, blogs) {
    final locale = Provider.of<AppModel>(context, listen: false).locale;
    if (widget.config.containsKey("name")) {
      var showSeeAllLink = widget.config['layout'] != "instagram";
      return HeaderView(
        headerText: widget.config["name"] != null
            ? widget.config["name"]
            : ' ',
        showSeeAll: showSeeAllLink,
        callback: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogScreen(blogs: blogs),
            ),
          )
        },
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var emptyPosts = [BlogNews.empty(0), BlogNews.empty(1), BlogNews.empty(2)];
    return Column(
      children: <Widget>[
        FutureBuilder<List<BlogNews>>(
          future: _fetchBlogs,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Column(
                  children: <Widget>[
                    _buildHeader(context, null),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: <Widget>[
                          BlogItem(
                            post: emptyPosts[0],
                            type: widget.config['type'],
                          ),
                          BlogItem(
                            post: emptyPosts[1],
                            type: widget.config['type'],
                          ),
                          BlogItem(
                            post: emptyPosts[2],
                            type: widget.config['type'],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
//                return Column(
//                  children: <Widget>[
//                    _buildHeader(context, null),
//                    BlogItemView(posts: emptyPosts, index: 0),
//                    BlogItemView(posts: emptyPosts, index: 1),
//                    BlogItemView(posts: emptyPosts, index: 2),
//                  ],
//                );
//                return Column(
//                  children: <Widget>[
//                    _buildHeader(context, null),
//                    SingleChildScrollView(
//                      scrollDirection: Axis.horizontal,
//                      child: Row(
//                        children: <Widget>[
//                          BlogItem(
//                            post: emptyPosts[0],
//                            type: widget.config['type'],
//                          ),
//                          BlogItem(
//                            post: emptyPosts[1],
//                            type: widget.config['type'],
//                          ),
//                          BlogItem(
//                            post: emptyPosts[2],
//                            type: widget.config['type'],
//                          ),
//                        ],
//                      ),
//                    )
//                  ],
//                );
//                return CircularProgressIndicator();
                break;
              case ConnectionState.done:
              default:
                if (snapshot.hasError) {
                  return Container();
                } else {
                  List<BlogNews> blogs = snapshot.data;
                  return Column(
                    children: <Widget>[
                      _buildHeader(context, blogs),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (var item in blogs)
                              BlogItem(
                                post: item,
                                //isHero: true,
                                type: widget.config['type'],
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
            }
          },
        ),
      ],
    );
  }
}

class BlogItem extends StatelessWidget {
  final BlogNews post;
  final String type;
  BlogItem({this.post, this.type});
  @override
  Widget build(BuildContext context) {
    double screenSize = MediaQuery.of(context).size.width;

    double _buildItemWidth() {
      switch (type) {
        case 'threeColumn':
          return screenSize / 3;
          break;
        case 'longImage':
          return screenSize / 1.5;
          break;
        default:
          return screenSize / 2;
      }
    }

    double _buildItemHeight() {
      switch (type) {
        case 'threeColumn':
          return screenSize / 3;
          break;
        case 'longImage':
          return screenSize / 2.5;
          break;
        default:
          return screenSize / 2;
      }
    }

    double _buildItemTitleFontSize() {
      switch (type) {
        case 'threeColumn':
          return 14;
          break;
        case 'longImage':
          return 18;
          break;
        default:
          return 15;
      }
    }

    return Container(
      padding: EdgeInsets.only(left: 10.0),
      width: _buildItemWidth(),
      height: _buildItemHeight(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 7,
            child: Tools.image(
                url: post.imageFeature, size: kSize.medium, fit: BoxFit.cover),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          ),
          Text(
            post.title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                color: Theme.of(context).accentColor,
                fontSize: _buildItemTitleFontSize(),
                fontWeight: FontWeight.w500),
            maxLines: 2,
          ),
          Text(
            post.date,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ],
      ),
    );
  }
}
