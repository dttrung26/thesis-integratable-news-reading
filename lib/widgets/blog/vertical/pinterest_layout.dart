import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../models/blog_news.dart';
import '../../../services/wordpress.dart';

import 'pinterest_card.dart';

class PinterestLayout extends StatefulWidget {
  final config;

  PinterestLayout({this.config});

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<PinterestLayout> {
  final WordPress _service = WordPress();
  List<BlogNews> _blogs = [];
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  _loadProduct() async {
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    var newBlogs = await _service.fetchBlogLayout(config: config);
    if (newBlogs != null)
      setState(() {
        _blogs = [..._blogs, ...newBlogs];
      });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MediaQuery.removePadding(
          context: context,
          removeTop: true,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 4,
            mainAxisSpacing: 4.0,
            shrinkWrap: true,
            primary: false,
            crossAxisSpacing: 4.0,
            itemCount: _blogs.length,
            itemBuilder: (context, index) => PinterestCard(
              item: _blogs[index],
              showOnlyImage: widget.config['showOnlyImage'],
              width: MediaQuery.of(context).size.width / 2,
              showCart: false,
            ),
            staggeredTileBuilder: (index) => StaggeredTile.fit(2),
          ),
        ),
      ],
    );
  }
}
