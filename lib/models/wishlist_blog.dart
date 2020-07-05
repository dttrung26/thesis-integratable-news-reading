import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../common/constants.dart';
import '../models/blog_news.dart';

class WishListModel extends ChangeNotifier {
  WishListModel() {
    getLocalWishlist();
  }

  List<BlogNews> blogs = [];

  List<BlogNews> getWishList() => blogs;

  void addToWishlist(BlogNews blog) {
    final isExist =
        blogs.firstWhere((item) => item.id == blog.id, orElse: () => null);
    if (isExist == null) {
      blogs.add(blog);
      saveWishlist(blogs);
      notifyListeners();
    }
  }

  void removeToWishlist(BlogNews blog) {
    final isExist =
        blogs.firstWhere((item) => item.id == blog.id, orElse: () => null);
    if (isExist != null) {
      blogs = blogs.where((item) => item.id != blog.id).toList();
      saveWishlist(blogs);
      notifyListeners();
    }
  }

  void saveWishlist(List<BlogNews> blogs) async {
    final LocalStorage storage = new LocalStorage("thesiscseiu");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["wishlist"], blogs);
      }
    } catch (err) {
      print(err);
    }
  }

  void getLocalWishlist() async {
    final LocalStorage storage = new LocalStorage("thesiscseiu");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem(kLocalKey["wishlist"]);

        if (json != null) {
          List<BlogNews> list = [];
          for (var item in json) {
            list.add(BlogNews.fromLocalJson(item));
          }

          blogs = list;
        }
      }
    } catch (err) {
      print(err);
    }
  }
}
