import 'package:flutter/material.dart';
import '../../models/category.dart';
import 'package:provider/provider.dart';
import 'menu_card.dart';

class HorizonMenu extends StatefulWidget {

  @override
  _StateHorizonMenu createState() => _StateHorizonMenu();
}

class _StateHorizonMenu extends State<HorizonMenu>{

  Future<List<Category>> getCategory() async {
    final categories = Provider.of<CategoryModel>(context, listen: false).categories;
    return categories.where((item) => item.parent == 0).toList();
  }

  List getChildrenOfCategory(List<Category> categories, Category category) {
    var children = categories.where((o) => o.parent == category.id).toList();
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final categories = Provider.of<CategoryModel>(context, listen: false).categories;
    
    return FutureBuilder<List<Category>>(
      future: getCategory(),
      builder: (context, snaphost){
        if (snaphost.hasData) {
          return Column(
            children: List.generate(snaphost.data.length, (index){
              return MenuCard(getChildrenOfCategory(categories, snaphost.data[index]), snaphost.data[index]);
            })
          );
        }
        return Container();
      },
    );
  }
}