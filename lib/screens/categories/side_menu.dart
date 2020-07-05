import 'package:flutter/material.dart';
import '../../models/category.dart';

class SideMenuCategories extends StatefulWidget {
  final List<Category> categories;

  SideMenuCategories(this.categories);

  @override
  State<StatefulWidget> createState() {
    return SideMenuCategoriesState();
  }
}

class SideMenuCategoriesState extends State<SideMenuCategories> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: <Widget>[
        Container(
          width: 100,
          child: ListView.builder(
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: selectedIndex == index ? Colors.grey[100] : Colors.white),
                  child: Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 15),
                    child: Center(
                      child: Text(
                        widget.categories[index] != null && widget.categories[index].name != null
                            ? widget.categories[index].name.toUpperCase()
                            : '',
                        style: TextStyle(
                          fontSize: 12,
                          color: selectedIndex == index ? theme.primaryColor : theme.hintColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
