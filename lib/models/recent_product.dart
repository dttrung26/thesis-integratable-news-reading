import 'package:flutter/material.dart';
import 'product.dart';
import 'blog_news.dart';

class RecentModel with ChangeNotifier {
  List<Product> products = [];
  List<BlogNews> blogs = [];

  void addRecentProduct(Product product) {
    products.removeWhere((index) => index.id == product.id);
    if (products.length == 20) products.removeLast();
    products.insert(0, product);
    notifyListeners();
  }

  void addRecentBlog(BlogNews blog) {
    blogs.removeWhere((index) => index.id == blog.id);
    if (blogs.length == 20) blogs.removeLast();
    blogs.insert(0, blog);
    notifyListeners();
  }
}
