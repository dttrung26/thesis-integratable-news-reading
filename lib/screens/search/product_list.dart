import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';

class ProductList extends StatefulWidget {
  final name;
  final padding;
  final products;

  ProductList({this.products, this.name, this.padding = 10.0});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  RefreshController _refreshController;
  Services _service = Services();
  List<Product> _products;
  int _page = 1;

  @override
  initState() {
    super.initState();
    _products = widget.products ?? [];
    _refreshController = RefreshController(initialRefresh: _products.length == 0);
  }

  @override
  didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_products != widget.products) {
      setState(() {
        _products = widget.products;
      });
    }
  }

  _loadProduct() async {
    var newProducts = await _service.searchProducts(name: widget.name, page: _page);
    _products = [..._products, ...newProducts];
  }

  _onRefresh() async {
    _page = 1;
    _products = [];
    _loadProduct();
    _refreshController.refreshCompleted();
  }

  _onLoading() async {
    _page = _page + 1;
    _loadProduct();
    _refreshController.loadComplete();
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthContent = (screenSize.width / 2) - 4;

    return SmartRefresher(
      header: MaterialClassicHeader(backgroundColor: Theme.of(context).primaryColor),
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: _products == null
          ? Container()
          : SingleChildScrollView(
              child: Wrap(
                children: <Widget>[
                  for (var i = 0; i < _products.length; i++)
                    ProductCard(item: _products[i], width: widthContent - 20)
                ],
              ),
            ),
    );
  }
}
