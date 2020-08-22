import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:notification_permissions/notification_permissions.dart';
import 'package:provider/provider.dart';
import 'package:rate_my_app/rate_my_app.dart';

import '../common/config.dart' as config;
import '../common/constants.dart';
import '../common/styles.dart';
import '../generated/l10n.dart';
import '../models/app.dart';
import '../models/user.dart';
import '../models/wishlist.dart';
import '../screens/chat/chat_list_by_admin.dart';
import '../screens/post_management/post_management.dart';
import '../widgets/smartchat.dart';
import 'language.dart';

class SettingScreen extends StatefulWidget {
  final User user;
  final VoidCallback onLogout;

  SettingScreen({this.user, this.onLogout});

  @override
  State<StatefulWidget> createState() {
    return SettingScreenState();
  }
}

class SettingScreenState extends State<SettingScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AfterLayoutMixin,
        AutomaticKeepAliveClientMixin<SettingScreen> {
  final bannerHigh = 200.0;
  bool enabledNotification = true;
  bool isAbleToPostManagement = false;

  void afterFirstLayout(BuildContext context) {
    debugPrint('widget.userrr ${widget.user}');
    if (widget.user != null) checkAddPostRole();
  }

  void checkAddPostRole() {
    debugPrint('user.roleee ${widget.user.role}');
    for (String legitRole in addPostAccessibleRoles) {
      if (widget.user.role == legitRole) {
        setState(() {
          isAbleToPostManagement = true;
        });
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  RateMyApp _rateMyApp = RateMyApp(
    minDays: 7,
    minLaunches: 10,
    remindDays: 7,
    remindLaunches: 10,
  );

  void checkNotificationPermission() async {
    try {
      NotificationPermissions.getNotificationPermissionStatus().then((status) {
        if (mounted)
          setState(() {
            enabledNotification = status == PermissionStatus.granted;
          });
      });
    } catch (err) {
//      print(err);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkNotificationPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    final wishListCount =
        Provider.of<WishListModel>(context, listen: false).blogs.length;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      floatingActionButton: (widget.user.username == config.adminEmail)
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListChat(user: widget.user))); //
              },
              child: Icon(
                Icons.chat,
                size: 22,
              ),
            )
          : SmartChat(user: widget.user),
//      body: Text("This is Setting screen"),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).primaryColor,
            leading: IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.black87,
              ),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            ),
            expandedHeight: bannerHigh,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(S.of(context).settings,
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                        fontWeight: FontWeight.w600)),
                background: Image.network(
                  kProfileBackground,
                  fit: BoxFit.cover,
                )),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      if (widget.user != null && widget.user.name != null)
                        ListTile(
                          leading: widget.user.picture != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(widget.user.picture))
                              : Icon(Icons.face),
                          title: Text(widget.user.name,
                              style: TextStyle(fontSize: 16)),
                        ),
                      if (widget.user != null && widget.user.email != null)
                        ListTile(
                          leading: Icon(Icons.email),
                          title: Text(widget.user.username ?? widget.user.email,
                              style: TextStyle(fontSize: 16)),
                        ),
                      SizedBox(height: 30.0),
                      Text(S.of(context).generalSetting,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10.0),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: ListTile(
                          leading: Image.asset(
                            'assets/icons/profile/icon-heart.png',
                            width: 20,
                            color: Theme.of(context).accentColor,
                          ),
                          title: Text(S.of(context).myWishList,
                              style: TextStyle(fontSize: 15)),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            if (wishListCount > 0)
                              Text(
                                "$wishListCount ${S.of(context).items}",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).primaryColor),
                              ),
                            SizedBox(width: 5),
                            Icon(Icons.arrow_forward_ios,
                                size: 18, color: kGrey600)
                          ]),
                          onTap: () {
                            Navigator.pushNamed(context, "/wishlist");
                          },
                        ),
                      ),

                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Language()));
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.language,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                            title: Text(S.of(context).language),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: kGrey600,
                            ),
                          ),
                        ),
                      ),
                      isAbleToPostManagement
                          ? Card(
                              margin: EdgeInsets.only(bottom: 2.0),
                              elevation: 0,
                              child: ListTile(
                                leading: Image.asset(
                                  'assets/icons/tabs/icon-cart2.png',
                                  width: 20,
                                  color: Theme.of(context).accentColor,
                                ),
                                title: Text(S.of(context).postManagement,
                                    style: TextStyle(fontSize: 15)),
                                trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.arrow_forward_ios,
                                          size: 18, color: kGrey600)
                                    ]),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PostManagementScreen(),
                                    ),
                                  );
                                },
                              ),
                            )
                          : Container(),
                      isAbleToPostManagement
                          ? Divider(
                              color: Colors.black12,
                              height: 1.0,
                              indent: 75,
                              //endIndent: 20,
                            )
                          : Container(),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: SwitchListTile(
                          secondary: Icon(
                            Icons.dashboard,
                            color: Theme.of(context).accentColor,
                            size: 24,
                          ),
                          value: Provider.of<AppModel>(context, listen: false)
                              .darkTheme,
                          activeColor: Color(0xFF0066B4),
                          onChanged: (bool value) {
                            if (value) {
                              Provider.of<AppModel>(context, listen: false)
                                  .updateTheme(true);
                            } else
                              Provider.of<AppModel>(context, listen: false)
                                  .updateTheme(false);
                          },
                          title: Text(
                            S.of(context).darkTheme,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
//                      Card(
//                        margin: EdgeInsets.only(bottom: 2.0),
//                        elevation: 0,
//                        child: ListTile(
//                          onTap: () {
//                            _rateMyApp
//                                .showRateDialog(context)
//                                .then((v) => setState(() {}));
//                          },
//                          leading: Image.asset(
//                            'assets/icons/profile/icon-star.png',
//                            width: 24,
//                            color: Theme.of(context).accentColor,
//                          ),
//                          title: Text(S.of(context).rateTheApp,
//                              style: TextStyle(fontSize: 16)),
//                          trailing: Icon(Icons.arrow_forward_ios,
//                              size: 18, color: kGrey600),
//                        ),
//                      ),
//                      Divider(
//                        color: Colors.black12,
//                        height: 1.0,
//                        indent: 75,
//                        //endIndent: 20,
//                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Language()));
                          },
                          child: ListTile(
                            leading: Icon(
                              Icons.create,
                              color: Theme.of(context).accentColor,
                              size: 24,
                            ),
                            title: Text(S.of(context).createPost),
                            trailing: Icon(
                              Icons.arrow_forward_ios,
                              size: 18,
                              color: kGrey600,
                            ),
                          ),
                        ),
                      ),
                      Divider(
                        color: Colors.black12,
                        height: 1.0,
                        indent: 75,
                        //endIndent: 20,
                      ),
                      Card(
                        margin: EdgeInsets.only(bottom: 2.0),
                        elevation: 0,
                        child: ListTile(
                          onTap: widget.onLogout,
                          leading: Image.asset(
                            'assets/icons/profile/icon-logout.png',
                            width: 24,
                            color: Theme.of(context).accentColor,
                          ),
                          title: Text(S.of(context).logout,
                              style: TextStyle(fontSize: 16)),
                          trailing: Icon(Icons.arrow_forward_ios,
                              size: 18, color: kGrey600),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
