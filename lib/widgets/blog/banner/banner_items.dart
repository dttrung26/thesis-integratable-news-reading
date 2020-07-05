import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/app.dart';
import '../../../models/blog_news.dart';
import '../../../services/wordpress.dart';

/// The Banner type to display the image
class BannerImageItem extends StatefulWidget {
  final Key key;
  final config;
  final double width;
  final padding;
  final BoxFit boxFit;
  final radius;

  BannerImageItem(
      {this.key,
      this.config,
      this.padding,
      this.width,
      this.boxFit,
      this.radius})
      : super(key: key);

  @override
  _BannerImageItemState createState() => _BannerImageItemState();
}

class _BannerImageItemState extends State<BannerImageItem>
    with AfterLayoutMixin {
//  BlogNews _blog;

  List<BlogNews> _blogs;

  WordPress _service = WordPress();

  @override
  void afterFirstLayout(BuildContext context) async {
    if (widget.config["category"] != null) {
      await _service
          .fetchBlogLayout(
              config: widget.config,
              lang: Provider.of<AppModel>(context, listen: false).locale)
          .then((blogs) {
        setState(() {
          _blogs = blogs;
          print(_blogs);
        });
      });
    }
  }

  _onTap(context) {
    /// support to show the product detail
//    if (widget.config["blog"] != null && _blog != null) {
//      return Navigator.push(
//          context,
//          MaterialPageRoute<void>(
//            builder: (BuildContext context) => Detail(product: _product),
//            fullscreenDialog: true,
//          ));
//    }
//
//    /// support to show the post detail
//    if (widget.config["post"] != null) {}

    /// Default navigate to show the list products
    BlogNews.showList(context: context, config: widget.config, blogs: _blogs);
  }

  @override
  Widget build(BuildContext context) {
    double _padding = widget.config["padding"] ?? widget.padding ?? 10.0;
    double _radius = widget.config['radius'] ??
        (widget.radius != null ? widget.radius : 0.0);

    final screenSize = MediaQuery.of(context).size;
    final itemWidth = widget.width ?? screenSize.width;

    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        width: itemWidth,
        child: Padding(
            padding: EdgeInsets.only(left: _padding, right: _padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_radius),
              child: Tools.image(
                fit: this.widget.boxFit ?? BoxFit.fitWidth,
                url: widget.config["image"],
              ),
            )),
      ),
    );
  }
}
