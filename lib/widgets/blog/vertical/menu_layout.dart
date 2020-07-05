import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/blog_news.dart';
import '../../../models/category.dart';
import '../../../services/wordpress.dart';
import '../../../widgets/blog_news/blog_card_view.dart';
import 'blog_select_card.dart';

class MenuLayout extends StatefulWidget {
  final config;

  MenuLayout({this.config});

  @override
  _StateSelectLayout createState() => _StateSelectLayout();
}

class _StateSelectLayout extends State<MenuLayout> {
  int position = 0;
  bool loading = false;
  List<List<BlogNews>> blogs = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getAllListBlogs({lang, page = 1, categories}) async {
    if (this.blogs.length > 0) return true;
    List<List<BlogNews>> blogs = [];
    WordPress _service = WordPress();
    for (var category in categories) {
      var blog = await _service.fetchBlogsByCategory(
          categoryId: category.id, lang: lang, page: page);
      blogs.add(blog);
      setState(() {
        this.blogs = blogs;
      });
    }
    return true;
  }

  Future<List<Category>> getAllCategory() async {
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    var listCategories = categories.where((item) => item.parent == 0).toList();
    List<Category> _categories = [];
    for (var category in listCategories) {
      var children = categories.where((o) => o.parent == category.id).toList();
      if (children.length > 0) {
        _categories = [..._categories, ...children];
      } else
        _categories = [..._categories, category];
    }
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: getAllCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return Column(
          children: <Widget>[
            Container(
              height: 70,
              padding: EdgeInsets.only(top: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(snapshot.data.length, (index) {
                  bool check = (blogs.length > index)
                      ? (blogs[index].length < 1 ? false : true)
                      : true;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        position = index;
                      });
                    },
                    child: !check
                        ? Container()
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  child: Text(
                                    snapshot.data[index].name.toUpperCase(),
                                    style: TextStyle(
                                        color: index == position
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).accentColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  padding: EdgeInsets.only(bottom: 8),
                                ),
                                index == position
                                    ? Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color:
                                                Theme.of(context).primaryColor),
                                        width: 20,
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                  );
                }),
              ),
            ),
            FutureBuilder<bool>(
              future: getAllListBlogs(categories: snapshot.data),
              builder: (context, check) {
                if (blogs.length < 1)
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    key: Key(snapshot.data[position].id.toString()),
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: 4,
                    itemBuilder: (context, value) {
                      return BlogCard(
                        item: BlogNews.empty(value),
                        width: MediaQuery.of(context).size.width / 2,
                      );
                    },
                    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                  );
                if (blogs[position].length == 0) {
                  return Container(
                    height: MediaQuery.of(context).size.width / 2,
                    child: Center(
                      child: Text(S.of(context).noProduct),
                    ),
                  );
                }
                return MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    key: Key(snapshot.data[position].id.toString()),
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: blogs[position].length,
                    itemBuilder: (context, value) {
                      return BlogSelectCard(
                        item: blogs[position][value],
                        width: MediaQuery.of(context).size.width / 2,
                      );
                    },
                    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
