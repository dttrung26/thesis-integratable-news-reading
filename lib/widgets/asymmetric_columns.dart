import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../models/cart.dart';
import '../common/tools.dart';
import '../models/recent_product.dart';
import '../screens/detail/index.dart';

class ProductCard extends StatelessWidget {
  ProductCard({this.imageAspectRatio = 33 / 49, this.product})
      : assert(imageAspectRatio == null || imageAspectRatio > 0);

  final double imageAspectRatio;
  final Product product;

  static final kTextBoxHeight = 65.0;


  onTapProduct(context) {
    if (product.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(product);
    print('item id: ${product.id}');
    Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => Detail(product: product),
          fullscreenDialog: true,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final addProductToCart = Provider.of<CartModel>(context, listen: false).addProductToCart;
    final imageWidget = Tools.image(url: product.imageFeature, isResize: true, fit: BoxFit.cover);

    return GestureDetector(
      onTap: () => onTapProduct(context),
      child: Container(
        child: Stack(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                AspectRatio(
                  aspectRatio: imageAspectRatio,
                  child: imageWidget,
                ),
                SizedBox(
                  height: kTextBoxHeight * MediaQuery.of(context).textScaleFactor,
//                width: 140.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        product == null ? '' : product.name,
                        style: theme.textTheme.button,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        product == null ? '' : Tools.getCurrecyFormatted(product.price),
                        style: theme.textTheme.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  addProductToCart(product: product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TwoProductCardColumn extends StatelessWidget {
  TwoProductCardColumn({
    this.bottom,
    this.top,
  }) : assert(bottom != null);

  final Product bottom, top;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
      const spacerHeight = 44.0;

      double heightOfCards = (constraints.biggest.height - spacerHeight) / 2.0;
      double heightOfImages = heightOfCards - ProductCard.kTextBoxHeight;
      double imageAspectRatio =
          (heightOfImages >= 0.0 && constraints.biggest.width > heightOfImages)
              ? constraints.biggest.width / heightOfImages
              : 33 / 49;

      return ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsetsDirectional.only(start: 28.0),
            child: top != null
                ? ProductCard(
                    imageAspectRatio: imageAspectRatio,
                    product: top,
                  )
                : SizedBox(
                    height: heightOfCards > 0 ? heightOfCards : spacerHeight,
                  ),
          ),
          SizedBox(height: spacerHeight),
          Padding(
            padding: EdgeInsetsDirectional.only(end: 28.0),
            child: ProductCard(
              imageAspectRatio: imageAspectRatio,
              product: bottom,
            ),
          ),
        ],
      );
    });
  }
}

class OneProductCardColumn extends StatelessWidget {
  OneProductCardColumn({this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return ListView(
      reverse: true,
      children: <Widget>[
        SizedBox(
          height: 40.0,
        ),
        ProductCard(
          product: product,
        ),
      ],
    );
  }
}
