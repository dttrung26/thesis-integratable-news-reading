import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/blog_news.dart';
import '../../services/wordpress.dart';
import '../../widgets/blog_news/blog_card_view.dart';

class BlogList extends StatefulWidget {
  final name;
  final padding;
  final blogs;

  BlogList({this.blogs, this.name, this.padding = 10.0});

  @override
  _BlogListState createState() => _BlogListState();
}

class _BlogListState extends State<BlogList> {
  RefreshController _refreshController;

  List<BlogNews> _blogs;
  int _page = 1;

  @override
  initState() {
    super.initState();
    _blogs = widget.blogs ?? [];
    _refreshController = RefreshController(initialRefresh: _blogs.length == 0);
  }

  @override
  didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_blogs != widget.blogs) {
      setState(() {
        _blogs = widget.blogs;
      });
    }
  }

  _loadProduct() async {
    var newBlogs = await WordPress().searchBlog(name: widget.name);
    _blogs = [..._blogs, ...newBlogs];
  }

  _onRefresh() async {
    _page = 1;
    _blogs = [];
    _loadProduct();
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    _page = _page + 1;
    _loadProduct();
    _refreshController.loadComplete();
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthContent = (screenSize.width / 2) - 3;
    print(_blogs);
    return SmartRefresher(
      header: MaterialClassicHeader(
          backgroundColor: Theme.of(context).primaryColor),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: Padding(
        padding: const EdgeInsets.only(left: 5),
        child: _blogs == null
            ? Container()
            : SingleChildScrollView(
                child: Wrap(
                  children: <Widget>[
                    for (var i = 0; i < _blogs.length; i++)
                      BlogCard(item: _blogs[i], width: widthContent - 20)
//                      BlogCardCanSwipe(blogs: _blogs, index: i, width: widthContent - 20)
                  ],
                ),
              ),
      ),
    );
  }
}
