import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/app.dart';
import '../../../models/blog_news.dart';
import '../../../models/recent_product.dart';
import '../../../services/wordpress.dart';
import '../../../widgets/blog/blog_staggered.dart';
import '../../../widgets/blog_news/blog_card_view.dart';
import '../header/header_view.dart';

class BlogListLayout extends StatefulWidget {
  final config;

  BlogListLayout({this.config});

  @override
  _ProductListItemsState createState() => _ProductListItemsState();
}

class _ProductListItemsState extends State<BlogListLayout> {
  final WordPress _service = WordPress();
  Future<List<BlogNews>> _getBlogsLayout;

  final _memoizer = AsyncMemoizer<List<BlogNews>>();

  @override
  void initState() {
    // only create the future once
    new Future.delayed(Duration.zero, () {
      setState(() {
        _getBlogsLayout = getBlogsLayout(context);
      });
    });
    super.initState();
  }

  double _buildProductWidth(screenWidth) {
    switch (widget.config["layout"]) {
      case "twoColumn":
        return screenWidth * 0.5;
      case "threeColumn":
        return screenWidth * 0.45;
      case "fourColumn":
        return screenWidth / 3;
      case "recentView":
        return screenWidth / 3;
      case "card":
      default:
        return screenWidth - 10;
    }
  }

  double _buildProductHeight(screenWidth, isTablet) {
    switch (widget.config["layout"]) {
      case "twoColumn":
      case "threeColumn":
      case "fourColumn":
      case "recentView":
        return screenWidth / 10;
        break;
      case "card":
      default:
        var cardHeight = widget.config["height"] != null
            ? widget.config["height"] + 40.0
            : screenWidth * 1.4;
        return isTablet ? screenWidth * 0.3 : cardHeight;
        break;
    }
  }

  Future<List<BlogNews>> getBlogsLayout(context) async {
//    if (widget.config["layout"] == "recentView")
//      return Provider.of<RecentModel>(context).products;
    return _memoizer.runOnce(
      () => _service.fetchBlogLayout(
          config: widget.config,
          lang: Provider.of<AppModel>(context, listen: false).locale),
    );
  }

  Widget getBlogsListWidgets(List<BlogNews> products, double width, context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          products.length,
          (index) {
            return BlogCard(
              item: products[index],
              width: _buildProductWidth(width),
              context: context,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recentProduct =
        Provider.of<RecentModel>(context, listen: false).products;
    final isRecent = widget.config["layout"] == "recentView" ? true : false;

    if (isRecent && recentProduct.length < 3) return Container();
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder<List<BlogNews>>(
          future: _getBlogsLayout,
          builder:
              (BuildContext context, AsyncSnapshot<List<BlogNews>> snapshot) {
            final locale = Provider.of<AppModel>(context, listen: false).locale;
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Column(
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
                          SizedBox(width: 10.0),
                          for (var i = 0; i < 4; i++)
                            BlogCard(
                              item: BlogNews.empty(i),
                              width: _buildProductWidth(constraints.maxWidth),
                            )
                        ],
                      ),
                    )
                  ],
                );
              case ConnectionState.done:

              default:
                if (snapshot.hasError || snapshot.data.length == 0) {
                  return Container();
                } else {
                  return Column(
                    children: <Widget>[
                      HeaderView(
                        headerText: widget.config["name"] != null
                            ? widget.config["name"]
                            : ' ',
                        showSeeAll: isRecent ? false : true,
                        callback: () => BlogNews.showList(
                            context: context,
                            config: widget.config,
                            blogs: isRecent ? recentProduct : snapshot.data),
                      ),
                      snapshot.hasError
                          ? Text('Getting Error')
                          : (widget.config["layout"] == "staggered"
                              ? BlogStaggered(snapshot.data)
                              : getBlogsListWidgets(snapshot.data,
                                  constraints.maxWidth, context)),
                    ],
                  );
                }
            }
          },
        );
      },
    );
  }
}
