import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../common/tools.dart';
import '../../models/blog_news.dart';
import '../../widgets/blog/detailed_blog/blog_view.dart';

import '../../widgets/heart_button.dart';

List<StaggeredTile> _staggeredTiles = const <StaggeredTile>[
  const StaggeredTile.count(2, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(3, 2),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
  const StaggeredTile.count(1, 1),
];

class BlogStaggered extends StatefulWidget {
  final List<BlogNews> blogs;

  BlogStaggered(this.blogs);

  @override
  _StateProductStaggered createState() => _StateProductStaggered();
}

class _StateProductStaggered extends State<BlogStaggered> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    double _size = MediaQuery.of(context).size.width / 3;

    return LayoutBuilder(
      builder: (context, constraints){
        return Container(
          padding: EdgeInsets.only(left: 15.0),
          height: MediaQuery.of(context).size.height* 0.4,
          child: StaggeredGridView.countBuilder(
            crossAxisCount: 3,
            scrollDirection: Axis.horizontal,
            itemCount: widget.blogs.length,
            itemBuilder: (context, index) {
              return Center(
                child: StaggeredBlogCard(
                  width: (constraints.maxWidth / 3) * _staggeredTiles[index % 6].mainAxisCellCount,
                  height:
                  (constraints.maxWidth / 3) * _staggeredTiles[index % 6].crossAxisCellCount - 20,
                  blogs: widget.blogs,
                  index: index,
                ),
              );
            },
            staggeredTileBuilder: (int index) => _staggeredTiles[index % 6],
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
        );
      }
    );
  }
}

class StaggeredBlogCard extends StatelessWidget {
  final width;
  final marginRight;
  final bool isHero;
  final bool showHeart;
  final height;
  final List<BlogNews> blogs;
  final int index;

  StaggeredBlogCard(
      {this.blogs,
      this.index,
      this.width,
      this.isHero = false,
      this.showHeart = false,
      this.height,
      this.marginRight = 10.0});

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: isHero
          ? Hero(
              tag: 'blog-${blogs[index].id}',
              child: Tools.image(
                url: blogs[index].imageFeature,
                width: width,
                size: kSize.medium,
                height: height ?? width * 1.2,
                fit: BoxFit.cover,
              ),
            )
          : Tools.image(
              url: blogs[index].imageFeature,
              width: width,
              size: kSize.medium,
              height: height ?? width * 1.2,
              fit: BoxFit.cover,
            ),
    );
  }

  onTapProduct(context) {
    if (blogs[index].imageFeature == '') return;
    print('item id: ${blogs[index].id}');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => getDetailPageView(blogs.sublist(index)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          color: Theme.of(context).cardColor,
          margin: EdgeInsets.only(right: 2),
          child: getImageFeature(
            () => onTapProduct(context),
          ),
        ),
        if (showHeart && !blogs[index].isEmptyBlog())
          Positioned(
            top: 0,
            right: 0,
            child: HeartButton(
              blog: blogs[index],
              size: 18,
            ),
          )
      ],
    );
  }
}
