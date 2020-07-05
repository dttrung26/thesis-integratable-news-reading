import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'common/config.dart' as config;
import 'common/config.dart';
import 'models/category.dart';
import 'models/app.dart';
import 'screens/categories/index.dart';
import 'widgets/blog/horizontal/slider_list.dart';
import 'screens/search/search.dart';
import 'screens/home.dart';
import 'screens/user.dart';
import 'screens/wishlist.dart';
import 'screens/webview_screen.dart';
import 'models/blog_news.dart';
import 'package:after_layout/after_layout.dart';
import 'widgets/icons/feather.dart';
import 'widgets/layout/adaptive.dart';
import 'menu.dart';
import 'route.dart';
import 'widgets/layout/layout_web.dart';
import 'dart:async';
import 'common/tools.dart';
//import 'widgets/layout/focus_traversal_policy.dart';

class MainTabs extends StatefulWidget {
//  static final GlobalKey<MainTabsState> keyNavigationTabbar = GlobalKey(debugLabel: 'homePageKey');
//  MainTabs({Key key}) : super(key: keyNavigationTabbar);

  @override
  State<StatefulWidget> createState() {
    return MainTabsState();
  }
}

class MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  StreamController<String> _controllerRouteWeb =
      StreamController<String>.broadcast();
  final _auth = FirebaseAuth.instance;

  InterstitialAd interstitialAd;
  FirebaseUser loggedInUser;
  int pageIndex = 0;
  int currentPage = 0;
  String currentTitle = "Home";
  Color currentColor = Colors.deepPurple;
  bool isAdmin = false;
  TabController tabController;
  Map saveIndexTab = Map();
  List<Widget> _tabView = [];

  void afterFirstLayout(BuildContext context) {
    loadTabBar();
  }

  Widget tabView(Map<String, dynamic> data) {
    switch (data['layout']) {
      case 'category':
        return CategoriesScreen();
      case 'search':
        return SearchScreen();
      case 'profile':
        return UserScreen();
      case 'blog':
        return HorizontalSliderList(config: data);
      case 'wishlist':
        return WishList();
      case 'page':
        return WebViewScreen(title: data['title'], url: data['url']);
      case 'dynamic':
      default:
        return HomeScreen();
    }
  }

  List<Widget> renderTabbar() {
    final tabData = Provider.of<AppModel>(context).appConfig['TabBar'] as List;
    List<Widget> list = [];

    tabData.asMap().forEach((i, item) {
      var icon = !item["icon"].contains('/')
          ? Icon(
              featherIcons[item["icon"]],
              color: Theme.of(context).accentColor,
              size: 22,
            )
          : (item["icon"].contains('http')
              ? Image.network(
                  item["icon"],
                  color: Theme.of(context).accentColor,
                  width: 22,
                )
              : Image.asset(
                  item["icon"],
                  color: Theme.of(context).accentColor,
                  width: 22,
                ));
      list.add(Tab(
        child: icon,
      ));
    });

    return list;
  }

  void loadTabBar() {
    final tabData = Provider.of<AppModel>(context, listen: false)
        .appConfig['TabBar'] as List;
    print(Provider.of<AppModel>(context, listen: false).appConfig['TabBar']);
    setState(() {
      tabController = TabController(length: tabData.length, vsync: this);
      currentPage = Provider.of<AppModel>(context, listen: false)
              .appConfig['tabSelected'] ??
          0;
    });
    tabController.animateTo(Provider.of<AppModel>(context, listen: false)
            .appConfig['tabSelected'] ??
        0);

    for (var i = 0; i < tabData.length; i++) {
      setState(() {
        _tabView.add(tabView(Map.from(tabData[i])));
      });
    }
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  List getChildren(List<Category> categories, Category category) {
    List<Widget> list = [];
    var children = categories.where((o) => o.parent == category.id).toList();
    if (children.length == 0) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(category.name),
            padding: EdgeInsets.only(left: 20),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            BlogNews.showList(
                context: context, cateId: category.id, cateName: category.name);
          },
        ),
      );
    }
    for (var i in children) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(i.name),
            padding: EdgeInsets.only(left: 20),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            BlogNews.showList(context: context, cateId: i.id, cateName: i.name);
          },
        ),
      );
    }
    return list;
  }

  List showCategories() {
    final categories = Provider.of<CategoryModel>(context).categories;
    List<Widget> widgets = [];

    if (categories != null) {
      var list = categories.where((item) => item.parent == 0).toList();
      for (var index in list) {
        widgets.add(
          ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: Text(
                index.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            children: getChildren(categories, index),
          ),
        );
      }
    }
    return widgets;
  }

  bool checkIsAdmin() {
    if (loggedInUser.email == config.adminEmail) {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    return isAdmin;
  }

  @override
  void initState() {
    getCurrentUser();

    super.initState();
  }

  Widget renderBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (kLayoutWeb) {
      final isDesktop = isDisplayDesktop(context);

      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          // For desktop layout we do not want to have SafeArea at the top and
          // bottom to display 100% height content on the accounts view.
          top: !isDesktop,
          bottom: !isDesktop,
          child: Theme(
              // This theme effectively removes the default visual touch
              // feedback for tapping a tab, which is replaced with a custom
              // animation.
              data: theme.copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: LayoutWebCustom(
                menu: MenuBar(controllerRouteWeb: _controllerRouteWeb),
                content: StreamBuilder<String>(
                    initialData: "/home-screen",
                    stream: _controllerRouteWeb.stream,
                    builder: (context, snapshot) {
                      return Navigator(
                        key: Key(snapshot.data),
                        initialRoute: snapshot.data,
                        onGenerateRoute: (RouteSettings settings) {
                          return MaterialPageRoute(
                              builder: kRouteApp[settings.name] ??
                                  kRouteApp["/home-screen"],
                              settings: settings,
                              maintainState: false,
                              fullscreenDialog: true);
                        },
                      );
                    }),
              )),
        ),
      );
    } else {
      final screenSize = MediaQuery.of(context).size;
      return Container(
        color: Theme.of(context).backgroundColor,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body: TabBarView(
            controller: tabController,
            physics: NeverScrollableScrollPhysics(),
            children: _tabView,
          ),
          drawer: Drawer(child: MenuBar()),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              width: screenSize.width,
              child: FittedBox(
                child: Container(
                  width: screenSize.width /
                      (2 / (screenSize.height / screenSize.width)),
                  child: TabBar(
                    controller: tabController,
                    tabs: renderTabbar(),
                    isScrollable: false,
                    labelColor: Theme.of(context).primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: EdgeInsets.all(4.0),
                    indicatorColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
//    bool loggedIn = Provider.of<UserModel>(context).loggedIn;
    setStatusBarWhiteForeground(false);
    if (_tabView.length < 1) {
      return Container();
    }

//    return DefaultFocusTraversal(
//        policy: EdgeChildrenFocusTraversalPolicy(
//          firstFocusNodeOutsideScope: null,
//          lastFocusNodeOutsideScope: null,
//          focusScope: FocusScope.of(context),
//        ),
    return renderBody(context);
  }
}
