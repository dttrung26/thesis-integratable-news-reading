import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app.dart';
import '../../../models/blog_news.dart';
import '../../../services/wordpress.dart';
import '../header/header_view.dart';
import '../vertical/vertical_simple_list.dart';

class SimpleVerticalProductList extends StatefulWidget {
  final config;

  SimpleVerticalProductList({this.config});

  @override
  _SimpleVerticalProductListState createState() =>
      _SimpleVerticalProductListState();
}

class _SimpleVerticalProductListState extends State<SimpleVerticalProductList> {
  final WordPress _service = WordPress();
  Future<List<BlogNews>> _getBlogLayout;

  final _memoizer = AsyncMemoizer<List<BlogNews>>();

  @override
  void initState() {
    // only create the future once
    new Future.delayed(Duration.zero, () {
      _getBlogLayout = getProductLayout(context);
    });
    super.initState();
  }

  Future<List<BlogNews>> getProductLayout(context) => _memoizer.runOnce(
        () => _service.fetchBlogLayout(
            config: widget.config, lang: Provider.of<AppModel>(context, listen: false).locale),
      );

  Widget renderProductListWidgets(List<BlogNews> blogs) {
    return Container(
      child: Column(
        children: [
          SizedBox(width: 10.0),
          for (var item in blogs)
            SimpleListView(
              item: item,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BlogNews>>(
      future: _getBlogLayout,
      builder: (BuildContext context, AsyncSnapshot<List<BlogNews>> snapshot) {
        final locale = Provider.of<AppModel>(context, listen: false).locale;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container(
              child: Column(
                children: <Widget>[
                  HeaderView(
                    headerText: widget.config["name"] != null
                        ? widget.config["name"][locale]
                        : '',
                    showSeeAll: true,
                    callback: () => BlogNews.showList(
                        context: context, config: widget.config),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var i = 0; i < 3; i++)
                          SimpleListView(
                            item: BlogNews.empty(i),
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          case ConnectionState.done:
          default:
            return Column(
              children: <Widget>[
                HeaderView(
                  headerText: widget.config["name"] != null
                      ? widget.config["name"][locale]
                      : '',
                  showSeeAll: true,
                  callback: () => BlogNews.showList(
                      context: context,
                      config: widget.config,
                      blogs: snapshot.data),
                ),
                snapshot.hasError ? Text('Getting Error') : renderProductListWidgets(snapshot.data)
              ],
            );
        }
      },
    );
  }
}
