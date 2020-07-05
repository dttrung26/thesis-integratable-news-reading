import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';

/// The category icon circle list
class CategoryItem extends StatelessWidget {
  final config;
  final item;
  final products;

  CategoryItem({this.config, this.item, this.products});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final categoryList = Provider.of<CategoryModel>(context, listen: false).categoryList;
    final id = item['category'];
    final name = categoryList[id] != null ? categoryList[id].name : '';
    final size = config['size'] ?? 1;
    final itemWidth = size * screenSize.width / 6;

    Widget getImageCategory = item['image'].indexOf('http') != -1
        ? Image.network(
            item['image'],
            color: HexColor(item["colors"][0]),
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          )
        : Image.asset(
            item["image"],
            color: HexColor(item["colors"][0]),
            width: itemWidth * 0.4 * size,
            height: itemWidth * 0.4 * size,
          );

    List<Color> colors = [];
    for (var item in item["colors"]) {
      colors.add(HexColor(item).withAlpha(30));
    }

    return GestureDetector(
        onTap: () => Product.showList(config: item, context: context),
        child: Container(
          width: itemWidth,
          height: 100 * size,
          margin: EdgeInsets.only(left: 10),
          padding: EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: config['noBackground'] == true
                    ? null
                    : BoxDecoration(
                  gradient: LinearGradient(colors: colors),
                  borderRadius: BorderRadius.circular(config['radius'] ?? itemWidth / 2),
                ),
                child: Padding(
                  padding: EdgeInsets.all(10.0 * size),
                  child: getImageCategory,
                ),
              ),
              SizedBox(height: 6),
              Expanded(
                child: Container(
                  child: Text(
                    name,
                    style: TextStyle(fontSize: 12 * size, color: Theme.of(context).accentColor),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

/// List of Category Items
class CategoryIcons extends StatelessWidget {
  final config;

  CategoryIcons({this.config});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width / 10;
    final heightList = itemWidth + 20;

    List<Widget> items = [];
    for (var item in config['items']) {
      items.add(CategoryItem(item: item, config: config));
    }

    /// if the wrap config is enable
    if (config['wrap'] == true) {
      return Wrap(children: items);
    }

    return Container(
      height: heightList + 40,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items,
        ),
      ),
    );
  }
}
