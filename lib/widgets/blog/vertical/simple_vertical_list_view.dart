import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/index.dart';
import '../../../common/tools.dart';
import '../../../models/app.dart';
import '../../../models/product.dart';
import '../../../screens/detail/index.dart';
import '../header/header_view.dart';

class SimpleVerticalProductList extends StatefulWidget {
  final config;

  SimpleVerticalProductList({this.config});

  @override
  _SimpleVerticalProductListState createState() => _SimpleVerticalProductListState();
}

class _SimpleVerticalProductListState extends State<SimpleVerticalProductList> {
  final Services _service = Services();
  Future<List<Product>> _getProductLayout;

  final _memoizer = AsyncMemoizer<List<Product>>();

  @override
  void initState() {
    // only create the future once
    new Future.delayed(Duration.zero, () {
      _getProductLayout = getProductLayout(context);
    });
    super.initState();
  }

  Future<List<Product>> getProductLayout(context) => _memoizer.runOnce(
        () => _service.fetchProductsLayout(
            config: widget.config, lang: Provider.of<AppModel>(context, listen: false).locale),
      );

  Widget renderProductListWidgets(List<Product> products) {
    return Container(
//      height: _buildProductHeight(screenSize.width, isTablet),
      child: Column(
        children: [
          SizedBox(width: 10.0),
          for (var item in products)
            SimpleProductCard(
              item: item,
              type: widget.config['type'],
              //isHero: true,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _getProductLayout,
      builder: (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
        final locale = Provider.of<AppModel>(context, listen: false).locale;
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Container(
              child: Column(
                children: <Widget>[
                  HeaderView(
                    headerText: widget.config["name"] != null ? widget.config["name"][locale] : '',
                    showSeeAll: true,
                    callback: () => Product.showList(context: context, config: widget.config),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        for (var i = 0; i < 3; i++)
                          SimpleProductCard(
                            item: Product.empty(i),
                            type: widget.config['type'],
                          ),
                      ],
                    ),
                  )
                ],
              ),
            );
          case ConnectionState.done:
          default:
            if (snapshot.hasError || snapshot.data.length == 0) {
              return Container();
            } else {
              return Column(
                children: <Widget>[
                  HeaderView(
                    headerText: widget.config["name"] != null ? widget.config["name"][locale] : '',
                    showSeeAll: true,
                    callback: () => Product.showList(
                        context: context, config: widget.config, products: snapshot.data),
                  ),
                  renderProductListWidgets(snapshot.data)
                ],
              );
            }
        }
      },
    );
  }
}

class SimpleProductCard extends StatelessWidget {
  final Product item;
  final String type;

  SimpleProductCard({this.item, this.type});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = 15;
    double imageWidth = 60;
    double imageHeight = 60;
    void onTapProduct() {
      if (item.imageFeature == '') return;
      print('item id: ${item.id}');
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Detail(product: item),
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
            color: type == 'withBackgroundColor' ? Theme.of(context).primaryColorLight : null,
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
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Tools.image(
                    url: item.imageFeature,
                    width: imageWidth,
                    size: kSize.medium,
                    isResize: true,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
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
                        item.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      (type != "withPriceOnTheRight")
                          ? Text(
                              Tools.getCurrecyFormatted(item.price),
                              style: TextStyle(color: Theme.of(context).accentColor),
                            )
                          : Container(),
                    ],
                  ),
                ),
                (type == "withPriceOnTheRight")
                    ? Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          Tools.getCurrecyFormatted(item.price),
                          style: TextStyle(color: Theme.of(context).accentColor),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
