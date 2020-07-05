import 'package:flutter/material.dart';
import '../common/constants.dart';
import '../services/wordpress.dart';

class CategoryModel with ChangeNotifier {
  WordPress _service = WordPress();
  List<Category> categories;
  Map<int, Category> categoryList = {};

  bool isLoading = true;
  String message;

  void getCategories({lang}) async {
    try {
      categories = await _service.getCategories(lang: lang);
      isLoading = false;

      for (Category cat in categories) {
        categoryList[cat.id] = cat;
      }

      print('This is list of your categories id');
      print(categories);

      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
    }
  }
}

class Category {
  int id;
  String name;
  String image;
  int parent;
  int totalProduct;

  Category.fromJson(Map<String, dynamic> parsedJson) {
    if (parsedJson["slug"] == 'uncategorized') {
      return;
    }

    id = parsedJson["id"];
    name = parsedJson["name"];
    parent = parsedJson["parent"];
    totalProduct = parsedJson["count"];

    final image = parsedJson["image"];
    if (image != null) {
      this.image = image["src"].toString();
    } else {
      this.image = kDefaultImage;
    }
  }

  @override
  String toString() => 'Category { id: $id  name: $name}';
}
