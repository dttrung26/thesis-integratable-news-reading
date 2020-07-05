import 'package:flutter/material.dart';
import '../../../common/tools.dart';
import '../../../models/product.dart';
import '../../../screens/detail/index.dart';
import '../../start_rating.dart';

class ProductSelectCard extends StatelessWidget {
  final Product item;
  final width;
  final marginRight;
  final kSize size;
  final bool isHero;
  final bool showCart;
  final bool showHeart;

  ProductSelectCard(
      {this.item,
      this.width,
      this.size = kSize.medium,
      this.isHero = false,
      this.showHeart = false,
      this.showCart = false,
      this.marginRight = 10.0});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    double titleFontSize = isTablet ? 20.0 : 14.0;
    double starSize = isTablet ? 20.0 : 13.0;

    Future<Widget> getImage() async {
      return ClipRRect(
        child: Tools.image(
          url: item.imageFeature,
          width: width,
          size: kSize.medium,
          isResize: true,
          fit: BoxFit.fill,
        ),
        borderRadius: BorderRadius.circular(10),
      );
    }

    void onTapProduct() {
      if (item.imageFeature == '') return;

      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Detail(product: item),
            fullscreenDialog: true,
          ));
    }

    return GestureDetector(
      onTap: onTapProduct,
      child: Container(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.all(5),
        child: Column(
          children: <Widget>[
            FutureBuilder<Widget>(
              future: getImage(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    width: width,
                    height: width * 1.2,
                  );
                return snapshot.data;
              },
            ),
            Container(
              width: width,
              alignment: Alignment.topLeft,
              padding: EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(item.name,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1),
                  SizedBox(height: 6),
                  Text(Tools.getCurrecyFormatted(item.price),
                      style: TextStyle(color: theme.accentColor)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      SmoothStarRating(
                          allowHalfRating: true,
                          starCount: 5,
                          rating: item.averageRating ?? 0.0,
                          size: starSize,
                          color: theme.primaryColor,
                          borderColor: theme.primaryColor,
                          spacing: 0.0),
//                      if (showCart && !item.isEmptyProduct())
//                        IconButton(
//                            padding: EdgeInsets.all(2.0),
//                            icon: Icon(Icons.add_shopping_cart, size: iconSize),
//                            onPressed: () {
//                              addProductToCart(product: item);
//                            }),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
