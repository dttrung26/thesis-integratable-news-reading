import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/tools.dart';
import '../../../models/app.dart';
import '../../../models/blog_news.dart';
import '../../../screens/blogs.dart';
import '../header/header_view.dart';

class SliderHorizontalList extends StatefulWidget {
  final config;

  SliderHorizontalList({this.config});

  @override
  _SliderHorizontalListState createState() => _SliderHorizontalListState();
}

class _SliderHorizontalListState extends State<SliderHorizontalList> {
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
        headerText: widget.config["name"][locale] ?? '',
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

  int _buildItemCount(List list, int itemNumber) {
    if (list.length % itemNumber == 0) {
      return (list.length ~/ itemNumber);
    } else
      return (list.length ~/ itemNumber) + 1;
  }

  @override
  Widget build(BuildContext context) {
    var emptyPosts = [BlogNews.empty(1), BlogNews.empty(2), BlogNews.empty(3)];
    var controller = PageController(viewportFraction: 1);
    return Container(
      padding: EdgeInsets.only(top: 20.0),
      child: FutureBuilder<List<BlogNews>>(
        future: _fetchBlogs,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
//                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                height: 450,
                child: Column(
                  children: <Widget>[
                    _buildHeader(context, null),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            BuildBlogCard(blog: emptyPosts[0]),
                            BuildBlogCard(blog: emptyPosts[1]),
                            BuildBlogCard(blog: emptyPosts[2]),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );

//              break;
            case ConnectionState.done:
            default:
              return Container(
//                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                height: 450,
                child: Column(
                  children: <Widget>[
                    _buildHeader(context, snapshot.data),
                    Expanded(
                      child: snapshot.hasError ? Text('Getting Error') : PageView.builder(
                        controller: controller,
                        itemBuilder: (context, index) {
                          if (index > 0 && index < snapshot.data.length) {
                            index *= 3;
                          }

                          return Padding(
                            padding: EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                for (var i = index; i < index + 3 && i < snapshot.data.length; i++)
                                  BuildBlogCard(
                                    blog: snapshot.data[i],
                                  )
                              ],
                            ),
                          );
                        },
                        itemCount: _buildItemCount(snapshot.data, 3),
                        scrollDirection: Axis.horizontal,
                      ),
                    )
                  ],
                ),
              );
          }
        },
      ),
    );
  }
}

class BuildBlogCard extends StatelessWidget {
  final BlogNews blog;

  BuildBlogCard({this.blog});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            height: 120,
            width: 120,
            child: Tools.image(url: blog.imageFeature, size: kSize.medium, fit: BoxFit.cover),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  blog.title,
                  style: TextStyle(
                    color: Theme.of(context).accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.left,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "by ${blog.author}",
                      style: TextStyle(
                        color: Theme.of(context).accentColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.right,
                    ),
                    Text(
                      blog.date,
                      style: TextStyle(
                        color: Theme.of(context).accentColor.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
