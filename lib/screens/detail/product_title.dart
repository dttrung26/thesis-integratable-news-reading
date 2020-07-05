import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../models/product.dart';
import '../../widgets/start_rating.dart';

class ProductTitle extends StatelessWidget {
  final Product product;

  ProductTitle(this.product);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    ProductVariation productVariation;
    productVariation =
        Provider.of<ProductModel>(context, listen: false).productVariation;

    final regularPrice = productVariation != null
        ? productVariation.regularPrice
        : product.regularPrice;
    final onSale =
        productVariation != null ? productVariation.onSale : product.onSale;
    final price =
        productVariation != null ? productVariation.price : product.price;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            product.name,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Text(Tools.getCurrecyFormatted(price),
                style: Theme.of(context)
                    .textTheme
                    .headline5
                    .copyWith(fontSize: 17, color: theme.accentColor)),
            if (onSale) SizedBox(width: 5),
            if (onSale)
              Text(Tools.getCurrecyFormatted(regularPrice),
                  style: Theme.of(context).textTheme.headline5.copyWith(
                      fontSize: 16,
                      color: Theme.of(context).accentColor,
                      decoration: TextDecoration.lineThrough)),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: product.averageRating,
                  size: 17.0,
                  color: theme.primaryColor,
                  borderColor: theme.primaryColor,
                  spacing: 0.0),
            ],
          ),
        ),
      ],
    );
  }
}
