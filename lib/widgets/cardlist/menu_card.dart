import 'package:flutter/material.dart';

import './list_card.dart';
import '../../models/category.dart';
import '../../models/product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';

class MenuCard extends StatefulWidget {
  final List<Category> categories;
  final Category category;

  MenuCard(this.categories, this.category);

  @override
  _StateMenuCard createState() => _StateMenuCard();
}

class _StateMenuCard extends State<MenuCard> {
  int position = 0;
  int pColor = 0;
  List<List<Product>> products = [];
  double _width = 0.0;
  int durations = 0;

  Future<List<Product>> getProductFromCategory(
      {categoryId, minPrice, maxPrice, orderBy, order, lang, page}) async {
    Services _service = Services();
    final product = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page);
    return product;
  }

  Future<List<List<Product>>> getAllListProducts(
      {minPrice, maxPrice, orderBy, order, lang, page = 1}) async {
    List<List<Product>> products = [];
    Services _service = Services();
    for (var category in widget.categories) {
      var product = await _service.fetchProductsByCategory(
          categoryId: category.id,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page);
      products.add(product);
    }
    return products;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            child: Text(
              widget.category.name.toUpperCase(),
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900),
            ),
            padding: EdgeInsets.only(bottom: 10),
          ),
          widget.categories.length == 0
              ? Container()
              : Container(
                  height: 26,
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: ClipRRect(
                                child: Container(
                                  child: Padding(
                                    child: Center(
                                      child: index == pColor
                                          ? Text(
                                              widget.categories[index].name,
                                              style: TextStyle(fontSize: 16, color: Colors.white),
                                            )
                                          : Text(
                                              widget.categories[index].name,
                                              style: TextStyle(fontSize: 16),
                                            ),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  ),
                                  decoration: BoxDecoration(
                                    color: index == pColor
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Container(
                              width: 10,
                            )
                          ],
                        ),
                        onTap: () async {
                          if (position == index) return;
                          setState(() {
                            _width = MediaQuery.of(context).size.width - 20;
                            durations = 0;
                            pColor = index;
                          });
                          await Future.delayed(Duration(milliseconds: 50));
                          setState(() {
                            position = index;
                            durations = 200;
                            _width = 0.0;
                          });
                        },
                      );
                    },
                    itemCount: widget.categories.length,
                    scrollDirection: Axis.horizontal,
                  ),
                ),
          widget.categories.length == 0
              ? Container()
              : Container(
                  height: 20,
                ),
          FutureBuilder<List<List<Product>>>(
              future: getAllListProducts(),
              builder: (context, snaphost) {
                if (!snaphost.hasData)
                  return Container(
                    height: MediaQuery.of(context).size.width * 0.35 + 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(3, (index) {
                        return ProductCard(
                          item: Product.empty(index),
                          width: MediaQuery.of(context).size.width * 0.35,
                        );
                      }),
                    ),
                  );
                if (snaphost.data.length == 0)
                  return FutureBuilder<List<Product>>(
                    future: getProductFromCategory(categoryId: widget.category.id, page: 1),
                    builder: (context, product) {
                      if (!product.hasData)
                        return Container(
                          height: MediaQuery.of(context).size.width * 0.35 + 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: List.generate(3, (index) {
                              return ProductCard(
                                item: Product.empty(index),
                                width: MediaQuery.of(context).size.width * 0.35,
                              );
                            }),
                          ),
                        );
                      return Container(
                        height: MediaQuery.of(context).size.width * 0.35 + 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: product.data.length,
                          itemBuilder: (context, index) {
                            return ProductCard(
                              item: product.data[index],
                              width: MediaQuery.of(context).size.width * 0.35,
                            );
                          },
                        ),
                      );
                    },
                  );
                return Container(
                  height: MediaQuery.of(context).size.width * 0.35 + 120,
                  child: Row(
                    children: <Widget>[
                      AnimatedContainer(
                        width: _width,
                        duration: Duration(milliseconds: durations),
                        decoration: BoxDecoration(),
                      ),
                      Expanded(
                        child: ListCard(snaphost.data[position], widget.categories[position].id),
                      )
                    ],
                  ),
                );
              }),
        ],
      ),
      padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
    );
  }
}
