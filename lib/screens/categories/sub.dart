import 'package:flutter/material.dart';
import '../../models/category.dart';

class SubCategories extends StatefulWidget {
  final List<Category> categories;
  SubCategories(this.categories);

  @override
  State<StatefulWidget> createState() {
    return SubCategoriesState();
  }
}

class SubCategoriesState extends State<SubCategories> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Center(
                    child: Text(widget.categories[index].name,
                        style: TextStyle(
                            fontSize: 18,
                            color: selectedIndex == index
                                ? theme.primaryColor
                                : theme.hintColor)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
