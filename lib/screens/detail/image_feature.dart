import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../models/product.dart';
import '../../widgets/image_galery.dart';

class ImageFeature extends StatelessWidget {
  final Product product;

  ImageFeature(this.product);

  @override
  Widget build(BuildContext context) {
    final widthScreen = MediaQuery.of(context).size.width;
    ProductVariation productVariation;
    productVariation = Provider.of<ProductModel>(context, listen: false).productVariation;
    final imageFeature =
        productVariation != null ? productVariation.imageFeature : product.imageFeature;

    _onShowGallery(context, [index = 0]) {
      showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return ImageGalery(images: product.images, index: index);
          });
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FlexibleSpaceBar(
          background: GestureDetector(
              onTap: () => _onShowGallery(context),
              child: Container(
                child: Stack(
                  children: <Widget>[
                    kProductDetail['isHero']
                        ? Positioned(
                            top: double.parse(kProductDetail['marginTop'].toString()),
                            child: Hero(
                              tag: 'product-${product.id}',
                              child: Tools.image(
                                url: imageFeature,
                                fit: BoxFit.contain,
                                isResize: true,
                                size: kSize.medium,
                                width: widthScreen,
                              ),
                            ),
                          )
                        : Positioned(
                            top: double.parse(kProductDetail['marginTop'].toString()),
                            child: Tools.image(
                              url: imageFeature,
                              fit: BoxFit.contain,
                              isResize: true,
                              size: kSize.medium,
                              width: widthScreen,
                            ),
                          ),
                    Positioned(
                      top: double.parse(kProductDetail['marginTop'].toString()),
                      child: Hero(
                        tag: 'product-${product.id}',
                        child: Tools.image(
                          url: imageFeature,
                          fit: BoxFit.contain,
                          width: widthScreen,
                          size: kSize.large,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
    );
  }
}
