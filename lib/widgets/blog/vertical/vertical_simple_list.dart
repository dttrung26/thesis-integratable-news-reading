import 'package:flutter/material.dart';

import '../../../common/tools.dart';
//import '../../../models/product.dart';
import '../../../models/blog_news.dart';
//import '../../../screens/detail/index.dart';
import '../../../widgets/blog/detailed_blog/blog_view.dart';
import '../../../widgets/heart_button.dart';

enum SimpleListType { BackgroundColor, PriceOnTheRight }

class SimpleListView extends StatelessWidget {
  final BlogNews item;
  final SimpleListType type;

  SimpleListView({this.item, this.type});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = 15;
    double imageWidth = 60;
    double imageHeight = 60;
    void onTapProduct() {
      if (item.imageFeature == '') return;
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => getDetailBlog(item),
            fullscreenDialog: true,
          ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: GestureDetector(
        onTap: onTapProduct,
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: type == SimpleListType.BackgroundColor
                ? Theme.of(context).primaryColorLight
                : null,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      child: Tools.image(
                        url: item.imageFeature,
                        width: imageWidth,
                        size: kSize.medium,
                        height: imageHeight,
                        fit: BoxFit.cover,
                      ),
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
                SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
