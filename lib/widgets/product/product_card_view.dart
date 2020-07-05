import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/cart.dart';
import '../../models/product.dart';
import '../../models/recent_product.dart';
import '../../screens/detail/index.dart';
import '../start_rating.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final width;
  final marginRight;
  final kSize size;
  final bool isHero;
  final bool showCart;
  final bool showHeart;
  final height;
  final bool hideDetail;
  final offset;

  ProductCard(
      {this.item,
      this.width,
      this.size = kSize.medium,
      this.isHero = false,
      this.showHeart = false,
      this.showCart = false,
      this.height,
      this.offset,
      this.hideDetail = false,
      this.marginRight = 6.0});

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: isHero
          ? Hero(
              tag: 'product-${item.id}',
              child: Tools.image(
                url: item.imageFeature,
                width: width,
                size: kSize.medium,
                isResize: true,
                height: height ?? width * 1.2,
                fit: BoxFit.cover,
              ),
            )
          : Tools.image(
              url: item.imageFeature,
              width: width,
              size: kSize.medium,
              isResize: true,
              height: height ?? width * 1.2,
              fit: BoxFit.cover,
              offset: offset ?? 0.0,
            ),
    );
  }

  onTapProduct(context) {
    if (item.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
    print('item id: ${item.id}');
    Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => Detail(product: item),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final addProductToCart = Provider.of<CartModel>(context, listen: false).addProductToCart;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    double titleFontSize = isTablet ? 20.0 : 14.0;
    double iconSize = isTablet ? 24.0 : 18.0;
    double starSize = isTablet ? 20.0 : 10.0;
    final gauss = offset != null ? math.exp(-(math.pow((offset.abs() - 0.5), 2) / 0.08)) : 0.0;

    if (hideDetail)
      return getImageFeature(
        () => onTapProduct(context),
      );

    return Stack(
      children: <Widget>[
        Container(
          width: width,
          margin: EdgeInsets.only(right: marginRight),
          padding: EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Container(
                  margin: EdgeInsets.only(bottom: 15.0),
                  child: Transform.translate(
                    offset: Offset(18 * gauss, 0.0),
                    child: getImageFeature(
                      () => onTapProduct(context),
                    ),
                  ),
                ),
              ),
              Text(item.name ?? '',
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
                  if (showCart && !item.isEmptyProduct())
                    IconButton(
                        padding: EdgeInsets.all(2.0),
                        icon: Icon(Icons.add_shopping_cart, size: iconSize),
                        onPressed: () {
                          addProductToCart(product: item);
                        }),
                ],
              )
            ],
          ),
        )
      ],
    );
  }
}
