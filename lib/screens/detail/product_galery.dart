import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/product.dart';
import '../../widgets/image_galery.dart';
import '../../widgets/webview.dart';

class ProductGalery extends StatelessWidget {
  final Product product;

  ProductGalery(this.product);

  _playVideo(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return WebView(url: product.videoUrl);
        });
  }

  _onShowGallery(context, [index = 0]) {
    showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return ImageGalery(images: product.images, index: index);
        });
  }

  @override
  Widget build(BuildContext context) {
    double dimension = MediaQuery.of(context).size.width * 0.31;

    if (product.images.length < kProductDetail['showThumbnailAtLeast'])
      return Container();

    return Container(
      height: dimension * 0.8 + 8,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(width: 4.0),
            if (product.videoUrl != null)
              InkWell(
                child: Container(
                  width: dimension,
                  height: dimension * 0.8,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: Tools.networkImage(product.imageFeature),
                        colorFilter: ColorFilter.mode(
                            Colors.black.withOpacity(0.2), BlendMode.dstATop)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.play_circle_outline,
                        size: 40,
                        color: Theme.of(context).accentColor,
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Text(
                        S.of(context).video,
                        style: TextStyle(color: Theme.of(context).accentColor),
                      )
                    ],
                  ),
                ),
                onTap: () => _playVideo(context),
              ),
            for (var i = 1; i < product.images.length; i++)
              GestureDetector(
                onTap: () => _onShowGallery(context, i),
                child: Padding(
                  padding: EdgeInsets.only(left: 4.0),
                  child: Tools.image(
                    url: product.images[i],
                    height: dimension * 0.8,
                    width: dimension,
                    isResize: true,
                    fit: BoxFit.cover,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
