import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

import './../generated/l10n.dart';
import './../models/product.dart';
import 'asymmetric_columns.dart';

class AsymmetricView extends StatefulWidget {
  final List<Product> products;
  final Function onLoadMore;
  final bool isFetching;
  final bool isEnd;

  const AsymmetricView(
      {Key key, this.products, this.isFetching, this.isEnd, this.onLoadMore});

  @override
  _AsymmetricViewState createState() => _AsymmetricViewState();
}

class _AsymmetricViewState extends State<AsymmetricView> {
  int _page = 1;

  _onLoading() async {
    if (!widget.isFetching && !widget.isEnd) {
      _page = _page + 1;
      widget.onLoadMore(_page);
    }
  }

  List<Container> _buildColumns(BuildContext context) {
    if (widget.products == null || widget.products.isEmpty) {
      return const <Container>[];
    }

    /// This will return a list of columns. It will oscillate between the two
    /// kinds of columns. Even cases of the index (0, 2, 4, etc) will be
    /// TwoProductCardColumn and the odd cases will be OneProductCardColumn.
    ///
    /// Each pair of columns will advance us 3 products forward (2 + 1). That's
    /// some kinda awkward math so we use _evenCasesIndex and _oddCasesIndex as
    /// helpers for creating the index of the product list that will correspond
    /// to the index of the list of columns.
    var productsList =
        List.generate(_listItemCount(widget.products.length), (int index) {
      double width = .59 * MediaQuery.of(context).size.width;
      Widget column;
      if (index % 2 == 0) {
        /// Even cases
        int bottom = _evenCasesIndex(index);
        column = TwoProductCardColumn(
            bottom: widget.products[bottom],
            top: widget.products.length - 1 >= bottom + 1
                ? widget.products[bottom + 1]
                : null);
        width += 32.0;
      } else {
        /// Odd cases
        column = OneProductCardColumn(
          product: widget.products[_oddCasesIndex(index)],
        );
      }

      return Container(
        width: width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: column,
        ),
      );
    }).toList();

    var loadingMore = Container(
      child: VisibilityDetector(
        key: Key("loading_visible"),
        child: Container(
          child: Center(
            child: Text(S.of(context).loading),
          ),
        ),
        onVisibilityChanged: (VisibilityInfo info) => _onLoading(),
      ),
    );

    return [...productsList, loadingMore];
  }

  int _evenCasesIndex(int input) {
    /// The operator ~/ is a cool one. It's the truncating division operator. It
    /// divides the number and if there's a remainder / decimal, it cuts it off.
    /// This is like dividing and then casting the result to int. Also, it's
    /// functionally equivalent to floor() in this case.
    return input ~/ 2 * 3;
  }

  int _oddCasesIndex(int input) {
    assert(input > 0);
    return (input / 2).ceil() * 3 - 1;
  }

  int _listItemCount(int totalItems) {
    if (totalItems % 3 == 0) {
      return totalItems ~/ 3 * 2;
    } else {
      return (totalItems / 3).ceil() * 2 - 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.fromLTRB(0.0, 34.0, 16.0, 44.0),
      children: _buildColumns(context),
      physics: AlwaysScrollableScrollPhysics(),
    );
  }
}
