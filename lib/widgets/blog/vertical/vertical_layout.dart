import 'package:flutter/material.dart';
import '../../../common/tools.dart';
import '../../../models/blog_news.dart';
import '../../../services/wordpress.dart';
import '../../../widgets/blog_news/blog_card_view.dart';
import 'vertical_simple_list.dart';

class VerticalViewLayout extends StatefulWidget {
  final config;

  VerticalViewLayout({this.config});

  @override
  _VerticalViewLayoutState createState() => _VerticalViewLayoutState();
}

class _VerticalViewLayoutState extends State<VerticalViewLayout> {
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
    setState(() {
      _blogs = [..._blogs, ...newBlogs];
    });
  }

  @override
  Widget build(BuildContext context) {
    var widthContent = 0.0;
    final screenSize = MediaQuery.of(context).size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final widthScreen = screenSize.width;

    if (widget.config['layout'] == "card") {
      widthContent = widthScreen; //one column
    } else if (widget.config['layout'] == "columns") {
      widthContent =
          isTablet ? widthScreen / 4 : (widthScreen / 3) - 15; //three columns
    } else {
      //layout is list
      widthContent =
          isTablet ? widthScreen / 3 : (widthScreen / 2) - 20; //two columns
    }

    return Padding(
      padding: EdgeInsets.only(left: 5.0),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: Wrap(
              children: <Widget>[
                for (var i = 0; i < _blogs.length; i++)
                  widget.config['layout'] == 'list'
                      ? SimpleListView(
                          item: _blogs[i], type: SimpleListType.BackgroundColor)
                      : BlogCard(
                          item: _blogs[i],
                          width: widthContent,
                        ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
