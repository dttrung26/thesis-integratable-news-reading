import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../models/blog_news.dart';
import '../services/wordpress.dart';

class SearchModel extends ChangeNotifier {
  SearchModel() {
    getKeywords();
  }

  List<String> keywords = [];
  List<BlogNews> blogs = [];
  bool loading = false;
  String errMsg;

  searchBlogs({String name}) async {
    try {
      loading = true;
      notifyListeners();
      blogs = await WordPress().searchBlog(name: name);
      if (blogs.length > 0 && name.isNotEmpty) {
        int index = keywords.indexOf(name);
        if (index > -1) {
          keywords.removeAt(index);
        }
        keywords.insert(0, name);
        saveKeywords(keywords);
      }
      loading = false;

      notifyListeners();
      return blogs;
    } catch (err) {
      loading = false;
      errMsg = err.toString();
      notifyListeners();
    }
  }

  void clearKeywords() {
    keywords = [];
    saveKeywords(keywords);
    notifyListeners();
  }

  void saveKeywords(List<String> keywords) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kLocalKey["recentSearches"], keywords);
    } catch (err) {
      print(err);
    }
  }

  void getKeywords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(kLocalKey["recentSearches"]);
      if (list != null && list.length > 0) {
        keywords = list;
      }
    } catch (err) {
//      print(err);
    }
  }
}
