import 'package:flutter/material.dart';
import '../../../common/tools.dart';
import '../../../models/blog_news.dart';
import '../detailed_blog/blog_view.dart';
import '../../../widgets/heart_button.dart';
//import '../../../models/product.dart';
//import '../../../screens/detail/index.dart';
//import '../../../widgets/start_rating.dart';

class PinterestCard extends StatelessWidget {
  final BlogNews item;
  final width;
  final marginRight;
  final kSize size;
  final bool isHero;
  final bool showCart;
  final bool showHeart;
  final bool showOnlyImage;

  PinterestCard(
      {this.item,
      this.width,
      this.size = kSize.medium,
      this.isHero = false,
      this.showHeart = true,
      this.showCart = false,
      this.showOnlyImage = false,
      this.marginRight = 10.0});

  @override
  Widget build(BuildContext context) {
    void onTapProduct() {
      if (item.imageFeature == '') return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => getDetailBlog(item),
        ),
      );
    }

    return GestureDetector(
      onTap: onTapProduct,
      child: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Tools.image(
                  url: item.imageFeature,
                  width: width,
                  size: kSize.medium,
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: HeartButton(
                    blog: item,
                  ),
                ),
              ],
            ),
            if (showOnlyImage == null || !showOnlyImage)
              Container(
                width: width,
                alignment: Alignment.topLeft,
                padding:
                    EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(height: 10.0),
                    Text(
                      item.title,
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.left,
                      maxLines: 2,
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      Tools.formatDateString(item.date),
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).accentColor.withOpacity(0.5),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}
