import 'dart:async';
import 'dart:ui';

import 'package:after_layout/after_layout.dart';
import 'package:custom_splash/custom_splash.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/styles.dart';
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'models/app.dart';
import 'models/blog_news.dart';
import 'models/category.dart';
import 'models/recent_product.dart';
import 'models/search.dart';
import 'models/user.dart';
import 'models/wishlist.dart';
import 'route.dart';
import 'screens/login.dart';
import 'screens/onboard_screen.dart';
import 'services/wordpress.dart';
import 'tabbar.dart';
import 'widgets/onesignal/onesignal.dart';

FirebaseAnalytics analytics = FirebaseAnalytics();

class App extends StatefulWidget {
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    MyOneSignal().oneSignalInit(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomSplash(
        imagePath: kLogoImage,
        backGroundColor: Colors.white,
        animationEffect: 'fade-in',
        logoSize: 50,
        home: MyApp(),
        duration: 2500,
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MyAppState();
  }
}

class MyAppState extends State<MyApp> with AfterLayoutMixin {
  final _app = AppModel();
  final _wishlist = WishListModel();
  final _search = SearchModel();
  final _recent = RecentModel();
  final _blog = BlogNewsModel();
  bool isFirstSeen = false;
  bool isChecking = true;
  bool isLoggedIn = false;

  @override
  void afterFirstLayout(BuildContext context) async {
    WordPress().setAppConfig(serverConfig);
    _app.loadAppConfig();
    isFirstSeen = await checkFirstSeen();
  }

  Widget renderFirstScreen() {
    if (isFirstSeen && !kIsWeb) return OnBoardScreen();
    if (kAdvanceConfig['IsRequiredLogin'] && !isLoggedIn) return LoginScreen();
    return MainTabs();
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _seen = (prefs.getBool('seen') ?? false);

    if (_seen)
      return false;
    else {
      prefs.setBool('seen', true);
      return true;
    }
  }

  Future checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('loggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppModel>.value(
      value: _app,
      child: Consumer<AppModel>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Container(
              color: Theme.of(context).backgroundColor,
            );
          }

          return MultiProvider(
            providers: [
              Provider<BlogNewsModel>.value(value: _blog),
              Provider<WishListModel>.value(value: _wishlist),
              Provider<SearchModel>.value(value: _search),
              Provider<RecentModel>.value(
                value: _recent,
              ),
              ChangeNotifierProvider(create: (context) => UserModel()),
              ChangeNotifierProvider(create: (context) => CategoryModel()),
            ],
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: new Locale(
                  Provider.of<AppModel>(context, listen: false).locale, ""),
              navigatorObservers: [
                FirebaseAnalyticsObserver(analytics: analytics),
              ],
//        i18n language translate support
//              localizationsDelegates: [
//                S.delegate,
//                GlobalMaterialLocalizations.delegate,
//                GlobalWidgetsLocalizations.delegate,
//              ],
//              supportedLocales: S.delegate.supportedLocales,
//              localeListResolutionCallback:
//                  S.delegate.listResolution(fallback: const Locale('en', '')),

              // l10n language support
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              home: Scaffold(
                body: renderFirstScreen(),
              ),
              routes: kRouteApp,
              theme: Provider.of<AppModel>(context, listen: false).darkTheme
                  ? buildDarkTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"]))
                  : buildLightTheme().copyWith(
                      primaryColor:
                          HexColor(_app.appConfig["Setting"]["MainColor"])),
            ),
          );
        },
      ),
    );
  }
}
