import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';

class AppModel with ChangeNotifier {
  Map<String, dynamic> appConfig;
  bool isLoading = true;
  String message;
  bool darkTheme = false;
  String locale = "en";
  String productListLayout;
  bool isAccessedByOnBoardingBoard = false;

  void changeLanguage(String country, BuildContext context) {
    locale = country;
    Provider.of<CategoryModel>(context, listen: false)
        .getCategories(lang: country);
    notifyListeners();
  }

  void updateTheme(bool theme) {
    darkTheme = theme;
    notifyListeners();
  }

  void loadAppConfig() async {
    try {
      //load local config file
      String path = "lib/common/config_$locale.json";
      try {
        final appJson = await rootBundle.loadString(path);
        appConfig = convert.jsonDecode(appJson);
      } catch (e) {
        throw (e);
      }
      productListLayout = appConfig['Setting']['ProductListLayout'];
      isLoading = false;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
    }
  }

  void updateProductListLayout(layout) {
    productListLayout = layout;
    notifyListeners();
  }
}

class App {
  Map<String, dynamic> appConfig;

  App(this.appConfig);
}
