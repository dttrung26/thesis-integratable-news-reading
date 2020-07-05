import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../models/category.dart';
import '../models/product.dart';

class GridCategory extends StatefulWidget {
  @override
  _StateGridCategory createState() => _StateGridCategory();
}

class _StateGridCategory extends State<GridCategory> {
  Future<List<Category>> getAllCategory() async {
    List<Category> _categories = [];
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    var listCategories = categories.where((item) => item.parent == 0).toList();
    for (var category in listCategories) {
      var children = categories.where((o) => o.parent == category.id).toList();
      if (children.length > 0)
        _categories = [..._categories, ...children];
      else
        _categories = [..._categories, category];
    }
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: getAllCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();
        return Padding(
          child: GridView.count(
              crossAxisCount: kAdvanceConfig['GridCount'],
              scrollDirection: Axis.vertical,
              children: List.generate(snapshot.data.length, (index) {
                return GestureDetector(
                  child: Card(
                    elevation: 1,
                    margin: EdgeInsets.all(10.0),
                    child: Padding(
                        child: Column(
                          children: <Widget>[
//                            Expanded(
//                              child: KoukIcons(
//                                name: kGridIconsCategories[index % kGridIconsCategories.length]
//                                    ['name'],
//                              ),
//                            ),
                            SizedBox(height: 8.0),
                            Text(
                              snapshot.data[index].name,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor),
                            ),
                          ],
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10)),
                  ),
                  onTap: () {
                    Product.showList(
                        context: context,
                        cateId: snapshot.data[index].id,
                        cateName: snapshot.data[index].name);
                  },
                );
              })),
          padding: EdgeInsets.symmetric(horizontal: 20),
        );
      },
    );
  }
}
