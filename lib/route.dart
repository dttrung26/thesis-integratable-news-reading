import 'package:flutter/material.dart';

import 'screens/blogs.dart';
import 'screens/categories/index.dart';
import 'screens/home.dart';
import 'screens/login.dart';
import 'screens/notification.dart';
import 'screens/products.dart';
import 'screens/registration.dart';
import 'screens/search/search.dart';
import 'screens/settings.dart';
import 'screens/wishlist.dart';
import 'tabbar.dart';

var kRouteApp = <String, WidgetBuilder>{
  "/home-screen": (context) => HomeScreen(),
  "/home": (context) => MainTabs(),
  "/login": (context) => LoginScreen(),
  "/register": (context) => RegistrationScreen(),
  '/products': (context) => ProductsPage(),
  '/wishlist': (context) => WishList(),
  '/blogs': (context) => BlogScreen(),
  '/notify': (context) => Notifications(),
  '/category': (context) => CategoriesScreen(),
  '/search': (context) => SearchScreen(),
  '/setting': (context) => SettingScreen()
};
