import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/category.dart';
import '../../../models/product.dart';

/// The category icon circle list
class CategoryItem extends StatelessWidget {
  final config;
  final products;

  CategoryItem({this.config, this.products});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width / 3;
    final categoryList = Provider.of<CategoryModel>(context, listen: false).categoryList;
    final id = config['category'];
    final name = categoryList[id] != null ? categoryList[id].name : '';
    final image = categoryList[id] != null ? categoryList[id].image : '';
    final total = categoryList[id] != null ? categoryList[id].totalProduct : '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, left: 5.0),
      child: GestureDetector(
        onTap: () => Product.showList(config: config, context: context),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: HexColor(
                "5F" + kColorNameToHex["grey"],
              ),
              width: 1.0,
            ),
            borderRadius: BorderRadius.all(Radius.circular(5.0)),
          ),
          width: itemWidth,
          height: 140.0,
          margin: EdgeInsets.only(left: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: itemWidth,
                height: itemWidth * 0.45,
                child: config["image"] != null
                    ? Image.asset(
                        config['image'],
                        fit: BoxFit.fitWidth,
                      )
                    : Tools.image(url: image, fit: BoxFit.cover, size: kSize.small),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(5.0), topRight: Radius.circular(5.0)),
                ),
              ),
              SizedBox(height: 6),
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 2),
                      Text(
                        config["name"] ?? name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        config["description"] ?? '$total products',
                        style: TextStyle(
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// List of Category Items
class CategoryImages extends StatelessWidget {
  final config;

  CategoryImages({this.config});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final itemWidth = screenSize.width / 10;
    final heightList = itemWidth + 22;

    List<Widget> items = [];
    for (var item in config['items']) {
      items.add(CategoryItem(config: item));
    }

    /// if the wrap config is enable
    if (config['wrap'] == true) {
      return Wrap(children: items);
    }

    return Container(
      height: heightList + 80,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: items,
        ),
      ),
    );
  }
}
