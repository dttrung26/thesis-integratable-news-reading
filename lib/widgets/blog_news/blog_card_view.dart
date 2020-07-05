import 'package:flutter/material.dart';

import '../../common/tools.dart';
import '../../models/blog_news.dart';
import '../../widgets/blog/detailed_blog/blog_view.dart';
import '../../widgets/heart_button.dart';

class BlogCard extends StatelessWidget {
  final BlogNews item;
  final width;
  final marginRight;
  final kSize size;
  final bool isHero;
  final height;
  final context;

  BlogCard({
    this.item,
    this.width,
    this.size = kSize.medium,
    this.isHero = false,
    this.height,
    this.marginRight = 10.0,
    this.context,
  });

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: isHero
          ? Hero(
              tag: 'product-${item.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                child: Tools.image(
                  url: item.imageFeature,
                  width: width,
                  height: height ?? width * 0.7,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              child: Tools.image(
                url: item.imageFeature,
                width: width,
                height: height ?? width * 0.7,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  onTapProduct(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => getDetailBlog(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isTablet = Tools.isTablet(MediaQuery.of(context));
//    double titleFontSize = isTablet ? 14.0 : 14.0;
    final double titleFontSize = 14.0;
    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: marginRight),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  getImageFeature(() => onTapProduct(context)),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: HeartButton(blog: item),
                  )
                ],
              ),
              Container(
                width: width,
                padding:
                    EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      item.date == ''
                          ? 'Loading ...'
                          : Tools.getTime(item.date, context: context),
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class BlogCardCanSwipe extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;
  final width;
  final marginRight;
  final kSize size;
  final bool isHero;
  final height;

  BlogCardCanSwipe(
      {this.blogs,
      this.index,
      this.width,
      this.size = kSize.medium,
      this.isHero = false,
      this.height,
      this.marginRight = 10.0});

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: isHero
          ? Hero(
              tag: 'product-${blogs[index].id}',
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(3.0)),
                child: Tools.image(
                  url: blogs[index].imageFeature,
                  width: width,
                  height: height ?? width * 0.7,
                  fit: BoxFit.cover,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              child: Tools.image(
                url: blogs[index].imageFeature,
                width: width,
                height: height ?? width * 0.7,
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  onTapProduct(context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => getDetailPageView(blogs.sublist(index)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    double titleFontSize = isTablet ? 20.0 : 14.0;

    return Stack(
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: marginRight),
          child: Column(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  getImageFeature(() => onTapProduct(context)),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: HeartButton(blog: blogs[index]),
                  )
                ],
              ),
              Container(
                width: width,
                padding:
                    EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      blogs[index].title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Text(
                      blogs[index].date == ''
                          ? 'Loading ...'
                          : Tools.getTime(blogs[index].date, context: context),
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
