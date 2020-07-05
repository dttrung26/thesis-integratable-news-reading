import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../models/product.dart';
import '../../widgets/product/product_card_view.dart';

class ProductList extends StatefulWidget {
  final List<Product> products;
  final bool isFetching;
  final bool isEnd;
  final String errMsg;
  final width;
  final padding;
  final String layout;
  final Function onRefresh;
  final Function onLoadMore;

  ProductList({
    this.isFetching = false,
    this.isEnd = true,
    this.errMsg,
    this.products,
    this.width,
    this.padding = 8.0,
    this.onRefresh,
    this.onLoadMore,
    this.layout = "list",
  });

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  RefreshController _refreshController;
  int _page = 1;

  List<Product> emptyList = [
    Product.empty(1),
    Product.empty(2),
    Product.empty(3),
    Product.empty(4),
    Product.empty(5),
    Product.empty(6)
  ];

  @override
  initState() {
    super.initState();

    /// if there are existing product from previous navigate we don't need to enable the refresh
    _refreshController = RefreshController(initialRefresh: false);
  }

  _onRefresh() async {
    if (!widget.isFetching) {
      _page = 1;
      widget.onRefresh();
    }
  }

  _onLoading() async {
    if (!widget.isFetching && !widget.isEnd) {
      _page = _page + 1;
      widget.onLoadMore(_page);
    }
  }

  @override
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFetching == false && oldWidget.isFetching == true) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    }
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery
        .of(context)
        .size;
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    final widthScreen = widget.width != null ? widget.width : screenSize.width;
    var widthContent = 0.0;

    if (widget.layout == "card") {
      widthContent = widthScreen; //one column
    } else if (widget.layout == "columns") {
      widthContent =
      isTablet ? widthScreen / 4 : (widthScreen / 3) - 14; //three columns
    } else {
      //layout is list
      widthContent =
      isTablet ? widthScreen / 3 : (widthScreen / 2) - 14; //two columns
    }

    final productsList = (widget.products == null || widget.products.isEmpty) &&
        widget.isFetching
        ? emptyList
        : widget.products;

    if (widget.errMsg != null && widget.errMsg.isNotEmpty) {
      return Center(
          child: Text(widget.errMsg, style: TextStyle(color: kErrorRed)));
    }

    if (productsList == null || productsList.isEmpty) {
      return Center(
          child: Text("No Product", style: TextStyle(color: Colors.black)));
    }

    return SmartRefresher(
      header: MaterialClassicHeader(
          backgroundColor: Theme
              .of(context)
              .primaryColor),
      enablePullDown: true,
      enablePullUp: !widget.isEnd,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: widget.layout != "pinterest" ? Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: SingleChildScrollView(
          child: Wrap(
            children: <Widget>[
              for (var i = 0; i < productsList.length; i++)
                ProductCard(
                  item: productsList[i],
                  showCart: widget.layout != "columns",
                  showHeart: true,
                  width: widthContent,
                  marginRight: widget.layout == "card" ? 0.0 : 10.0,
                )
            ],
          ),
        ),
      ) : Container()
    );
  }
}
