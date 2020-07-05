import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/category.dart';
import '../../widgets/grid_category.dart';
import 'card.dart';
import 'column.dart';
import 'side_menu.dart';
import 'sub.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  FocusNode _focus;
  bool isVisibleSearch = false;
  String searchText;
  var textController = new TextEditingController();

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = new FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context, listen: false);

    return ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return kLoadingWidget(context);
            }

            if (value.message != null) {
              return Center(
                child: Text(value.message),
              );
            }

            if (value.categories == null) {
              return null;
            }

            return Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: SafeArea(
                  child: [
                kCategoriesLayout.grid,
                kCategoriesLayout.column,
                kCategoriesLayout.sideMenu,
                kCategoriesLayout.subCategories
              ].contains(CategoriesListLayout)
                      ? Column(
                          children: <Widget>[
                            Padding(
                              child: Text(
                                S.of(context).category,
                                style: TextStyle(
                                    fontSize: 27, fontWeight: FontWeight.bold),
                              ),
                              padding: EdgeInsets.only(
                                  top: 10, left: 10, bottom: 20, right: 10),
                            ),
                            Expanded(
                              child: renderCategories(value),
                            )
                          ],
                        )
                      : ListView(
                          children: <Widget>[
                            Padding(
                              child: Text(
                                S.of(context).category,
                                style: TextStyle(
                                    fontSize: 27, fontWeight: FontWeight.bold),
                              ),
                              padding: EdgeInsets.only(
                                  top: 10, left: 10, bottom: 20, right: 10),
                            ),
                            renderCategories(value)
                          ],
                        )),
            );
          },
        ));
  }

  Widget renderCategories(value) {
    switch (CategoriesListLayout) {
      case kCategoriesLayout.card:
        return CardCategories(value.categories);
      case kCategoriesLayout.column:
        return ColumnCategories(value.categories);
      case kCategoriesLayout.subCategories:
        return SubCategories(value.categories);
      case kCategoriesLayout.sideMenu:
        return SideMenuCategories(value.categories);
      case kCategoriesLayout.grid:
        return GridCategory();
      default:
        return CardCategories(value.categories);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
