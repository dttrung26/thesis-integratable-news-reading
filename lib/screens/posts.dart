import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/app.dart';
import '../models/blog_news.dart';
import '../models/product.dart';
import '../services/index.dart';
import '../widgets/backdrop.dart';
import '../widgets/backdrop_menu.dart';
import '../widgets/blog_news/blog_list.dart';

class PostBackdrop extends StatelessWidget {
//  final ExpandingBottomSheet expandingBottomSheet;
  final Backdrop backdrop;

  const PostBackdrop({Key key, this.backdrop}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        backdrop,
      ],
    );
  }
}

class BlogsPage extends StatefulWidget {
  final List<BlogNews> blogs;
  final int categoryId;
  final config;

  BlogsPage({this.blogs, this.categoryId, this.config});

  @override
  _BlogsPageState createState() => _BlogsPageState();
}

class _BlogsPageState extends State<BlogsPage>
    with SingleTickerProviderStateMixin {
  int newCategoryId = -1;
  double minPrice;
  double maxPrice;
  String orderBy;
  String order;
  bool isFiltering = false;
  List<Product> products = [];
  String errMsg;

  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    setState(() {
      newCategoryId = widget.categoryId;
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
      value: 1.0,
    );

    if (widget.config != null) {
      onRefresh();
    }
  }

  void onFilter({minPrice, maxPrice, categoryId}) {
    _controller.forward();
    final blogNewsModel = Provider.of<BlogNewsModel>(context, listen: false);
    newCategoryId = categoryId;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    blogNewsModel.setBlogNewsList(List<BlogNews>());
    blogNewsModel.getBlogsList(
        categoryId: categoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        page: 1,
        lang: Provider.of<AppModel>(context, listen: false).locale,
        orderBy: orderBy,
        order: order);
  }

  void onSort(order) {
    orderBy = "date";
    this.order = order;
    Provider.of<BlogNewsModel>(context, listen: false).getBlogsList(
        categoryId: newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).locale,
        page: 1,
        orderBy: orderBy,
        order: order);
  }

  void onRefresh() async {
    if (widget.config == null) {
      Provider.of<BlogNewsModel>(context, listen: false).getBlogsList(
          categoryId: newCategoryId,
          minPrice: minPrice,
          maxPrice: maxPrice,
          lang: Provider.of<AppModel>(context, listen: false).locale,
          page: 1,
          orderBy: orderBy,
          order: order);
    } else {
      try {
        var newProducts =
            await Services().fetchProductsLayout(config: widget.config);
        setState(() {
          products = newProducts;
        });
      } catch (err) {
        setState(() {
          errMsg = err;
        });
      }
    }
  }

  void onLoadMore(page) {
    Provider.of<BlogNewsModel>(context, listen: false).getBlogsList(
        categoryId: newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).locale,
        page: page,
        orderBy: orderBy,
        order: order);
  }

  @override
  Widget build(BuildContext context) {
    final blog = Provider.of<BlogNewsModel>(context, listen: false);
    final title = blog.categoryName ?? S.of(context).blog;
    print(title);
    final layout = widget.config != null && widget.config["layout"] != null
        ? widget.config["layout"]
        : Provider.of<AppModel>(context, listen: false).productListLayout;

    final backdrop = ({blogs, isFetching, errMsg, isEnd}) => PostBackdrop(
          backdrop: Backdrop(
            frontLayer: BlogList(
                blogs: blogs,
                onRefresh: onRefresh,
                onLoadMore: onLoadMore,
                isFetching: isFetching,
                errMsg: errMsg,
                isEnd: isEnd,
                layout: layout),
            backLayer: BackdropMenu(onFilter: onFilter),
            frontTitle: Text(title),
            backTitle: Text('Filters'),
            controller: _controller,
            onSort: onSort,
          ),
        );

    return ListenableProvider.value(
      value: blog,
      child: Consumer<BlogNewsModel>(builder: (context, value, child) {
        return backdrop(
            blogs: value.blogList,
            isFetching: value.isFetching,
            errMsg: value.errMsg,
            isEnd: value.isEnd);
      }),
    );
  }
}
