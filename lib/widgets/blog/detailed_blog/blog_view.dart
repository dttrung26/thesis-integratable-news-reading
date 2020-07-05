import 'package:flutter/material.dart';
import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import 'detailed_blog_fullsize_image.dart';
import 'detailed_blog_half_image.dart';
import 'detailed_blog_quarter_image.dart';
import '../../../models/blog_news.dart';
import '../../../widgets/heart_button.dart';

Widget getDetailPageView(List<BlogNews> blogs) {
  return PageView.builder(
    itemCount: blogs.length,
    itemBuilder: (context, position) {
      return getDetailScreen(blogs, position);
    },
  );
}

Widget getDetailScreen(List<BlogNews> blogs, index) {
  switch (kAdvanceConfig['DetailedBlogLayout']) {
    case kBlogLayout.halfSizeImageType:
      return HalfImageType(item: blogs[index]);
    case kBlogLayout.fullSizeImageType:
      return FullImageType(item: blogs[index]);
    case kBlogLayout.oneQuarterImageType:
      return OneQuarterImageType(item: blogs[index]);
    default:
      return HalfImageType(item: blogs[index]);
  }
}

Widget getDetailBlog(BlogNews blog) {
  print(kAdvanceConfig['DetailedBlogLayout']);
  switch (kAdvanceConfig['DetailedBlogLayout']) {
    case kBlogLayout.halfSizeImageType:
      return HalfImageType(item: blog);

    case kBlogLayout.fullSizeImageType:
      return FullImageType(
        item: blog,
      );
    case kBlogLayout.oneQuarterImageType:
      return OneQuarterImageType(
        item: blog,
      );
    default:
      return HalfImageType(item: blog);
  }
}

double _buildBlogFontSize(String type) {
  switch (type) {
    case "twoColumn":
      return 16;
    case "threeColumn":
      return 15;
    case "fourColumn":
      return 13;
    case "recentView":
      return 13;
    case "card":
    default:
      return 13;
  }
}

double _buildProductWidth(screenWidth, String layout) {
  switch (layout) {
    case "twoColumn":
      return screenWidth * 0.5;
    case "threeColumn":
      return screenWidth * 0.35;
    case "fourColumn":
      return screenWidth / 4;
    case "recentView":
      return screenWidth / 4;
    case "card":
    default:
      return screenWidth - 10;
  }
}

class BlogNewsView extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;

  const BlogNewsView({this.blogs, this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => getDetailPageView(blogs.sublist(index)),
          ),
        );
      },
      child: ListTile(
        leading: Container(
          width: 100,
          height: 100,
          padding: EdgeInsets.symmetric(vertical: 4.0),
          alignment: Alignment.center,
          child: Hero(
              tag: 'blog-${blogs[index].id}',
              child: Tools.image(
                  url: blogs[index].imageFeature, size: kSize.medium),
              transitionOnUserGestures: true),
        ),
        title: Text(blogs[index].title),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 5.0),
          child: Text(
            blogs[index].date,
            style: TextStyle(fontSize: 12, color: Colors.black45),
          ),
        ),
        dense: false,
      ),
    );
  }
}

class BlogCardView extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;
  final String type;
  final double width;

  BlogCardView({this.blogs, this.index, this.type, this.width});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => getDetailPageView(blogs.sublist(index)),
          ),
        );
      },
      child: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.only(right: 0, left: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.circular(3.0),
                  child: Hero(
                    tag: 'blog-${blogs[index].id}',
                    child: Tools.image(
                      url: blogs[index].imageFeature,
                      width: _buildProductWidth(width, type),
                      height: screenWidth * 0.15,
                      fit: BoxFit.cover,
                      size: kSize.medium,
                    ),
                  ),
                ),

                SizedBox(height: 10.0),
                Text(
                  blogs[index].title,
                  style: TextStyle(
                      fontSize: _buildBlogFontSize(type),
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.left,
                  maxLines: 2,
                ),
                SizedBox(height: 10.0),
                Text(
                  Tools.formatDateString(blogs[index].date),
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).accentColor.withOpacity(0.5),
                  ),
                  maxLines: 2,
                ),
//
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: HeartButton(
              blog: blogs[index],
            ),
          ),
        ],
      ),
    );
  }
}
