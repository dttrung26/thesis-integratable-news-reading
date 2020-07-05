import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/app.dart';
import '../../../models/blog_news.dart';
import '../../../services/wordpress.dart';
import '../../../widgets/blog/detailed_blog/blog_view.dart';
import '../../../widgets/heart_button.dart';
import '../header/header_view.dart';

class LargeCardHorizontalListItems extends StatefulWidget {
  final config;

  LargeCardHorizontalListItems({this.config});

  @override
  _LargeCardHorizontalListItemsState createState() =>
      _LargeCardHorizontalListItemsState();
}

class _LargeCardHorizontalListItemsState
    extends State<LargeCardHorizontalListItems> {
  final WordPress _service = WordPress();
  Future<List<BlogNews>> _getBlogsLayout;
  final _memoizer = AsyncMemoizer<List<BlogNews>>();
  final blogEmptyList = [
    BlogNews.empty(1),
    BlogNews.empty(2),
    BlogNews.empty(3)
  ];

  @override
  void initState() {
    // only create the future once
    new Future.delayed(Duration.zero, () {
      setState(() {
        _getBlogsLayout = getBlogLayout(context);
      });
    });
    super.initState();
  }

  Future<List<BlogNews>> getBlogLayout(context) async {
    return _memoizer.runOnce(
      () => _service.fetchBlogLayout(
          config: widget.config,
          lang: Provider.of<AppModel>(context, listen: false).locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppModel>(context, listen: false).locale;
    final isRecent = widget.config["layout"] == "recentView" ? true : false;
    final double imageBorder =
        double.tryParse(widget.config["imageBorder"].toString()) ?? 3.0;

    return LayoutBuilder(builder: (context, contraints) {
      return FutureBuilder<List<BlogNews>>(
        future: _getBlogsLayout,
        builder:
            (BuildContext context, AsyncSnapshot<List<BlogNews>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Padding(
                  padding: EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        HeaderView(
                          headerText: widget.config["name"] != null
                              ? widget.config["name"]
                              : ' ',
                          showSeeAll: isRecent ? false : true,
                          callback: () => BlogNews.showList(
                              context: context,
                              config: widget.config,
                              blogs: snapshot.data),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var i = 0; i < 3; i++)
                                LargeBlogCard(
                                  blogs: blogEmptyList,
                                  index: i,
                                  width: widget.config['imageWidth'] != null
                                      ? double.parse(widget.config['imageWidth']
                                          .toString())
                                      : contraints.maxWidth / 2,
                                  imageBorder: imageBorder,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ));
            case ConnectionState.done:
            default:
              return Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Column(
                  children: <Widget>[
                    HeaderView(
                      headerText: widget.config["name"] != null
                          ? widget.config["name"]
                          : ' ',
                      showSeeAll: isRecent ? false : true,
                      callback: () => BlogNews.showList(
                          context: context,
                          config: widget.config,
                          blogs: snapshot.data),
                    ),
                    snapshot.hasError
                        ? Text('Getting Error')
                        : SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
//                        children: <Widget>[BlogListWidgets(snapshot.data)],
                              children: List.generate(
                                snapshot.data.length,
                                (index) {
                                  return Container(
                                    child: LargeBlogCard(
                                      blogs: snapshot.data,
                                      index: index,
                                      width: widget.config['imageWidth'] != null
                                          ? double.parse(widget
                                              .config['imageWidth']
                                              .toString())
                                          : contraints.maxWidth / 2,
                                      imageBorder: imageBorder,
                                      context: context,
                                      //isHero: true,
                                    ),
//                            child: BlogCardView(
//                              blogs: snapshot.data,
//                              index: index,
//                            ),
                                  );
                                },
                              ),
                            ),
                          ),
                  ],
                ),
              );
          }
        },
      );
    });
  }
}

class LargeBlogCard extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;
  final double width;
  final double imageBorder;
  final context;
  LargeBlogCard(
      {this.blogs, this.index, this.width, this.imageBorder, this.context});

  @override
  Widget build(BuildContext context) {
//    var screenWidth = MediaQuery.of(context).size.width;
    double imageWidth = width;
    double titleFontSize = imageWidth / 10;

    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => getDetailPageView(blogs.sublist(index)),
            ),
          );
        },
        child: Container(
          child: Stack(
            children: <Widget>[
              Hero(
                tag: 'blog-${blogs[index].id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.all(
                    Radius.circular(imageBorder),
                  ),
                  child: Tools.image(
                    url: blogs[index].imageFeature,
                    width: imageWidth,
                    height: imageWidth * 1.7,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: imageWidth,
                height: imageWidth * 1.7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(imageBorder)),
                  gradient: LinearGradient(
                      colors: [Colors.black54, Colors.black26, Colors.black12],
                      stops: [0.4, 0.7, 0.9],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center),
                ),
              ),
              Positioned(
                bottom: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    width: imageWidth - 30,
                    height: imageWidth * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          blogs[index].title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(
                          height: imageWidth / 35,
                        ),
                        Text(
                          blogs[index].date == ''
                              ? 'Loading ...'
                              : Tools.getTime(blogs[index].date,
                                  context: context),
                          style: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: HeartButton(
                  blog: blogs[index],
                  size: 23,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
