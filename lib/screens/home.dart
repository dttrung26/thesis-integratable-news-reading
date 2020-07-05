import 'dart:async';
import 'dart:io';
import 'package:after_layout/after_layout.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import '../common/constants.dart';
import '../models/app.dart';
import '../models/category.dart';
import '../models/notification.dart';
import '../widgets/blog/index.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, AfterLayoutMixin<HomeScreen> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  Uri _latestUri;
  StreamSubscription _sub;
  int itemSlug;

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    initPlatformState();
    firebaseCloudMessagingListeners();
  }

  initPlatformState() async {
    await initPlatformStateForStringUniLinks();
  }

  initPlatformStateForStringUniLinks() async {
    // Attach a listener to the links stream
    _sub = getLinksStream().listen((String link) {
      setState(() {
        _latestUri = null;
        try {
          if (link != null) _latestUri = Uri.parse(link);

          setState(() {
            itemSlug = int.parse(_latestUri.path.split('/')[1]);
            print('item slug $itemSlug');
          });

//          Navigator.push(
//            context,
//            MaterialPageRoute(
//                builder: (context) => ItemDeepLink(
//                      itemSlug: itemSlug,
//                    )),
//          );
        } on FormatException {}
      });
    }, onError: (err) {
      setState(() {
        _latestUri = null;
      });
    });

    getLinksStream().listen((String link) {
      print('got link: $link');
    }, onError: (err) {
      print('got err: $err');
    });
  }

  _saveMessage(message) {
    FStoreNotification a = FStoreNotification.fromJsonFirebase(message);
    a.saveToLocal(message['notification'] != null
        ? message['notification']['tag']
        : message['data']['google.message_id']);
  }

  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => _saveMessage(message),
      onResume: (Map<String, dynamic> message) => _saveMessage(message),
      onLaunch: (Map<String, dynamic> message) => _saveMessage(message),
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

  @override
  void afterFirstLayout(BuildContext context) {
    Provider.of<CategoryModel>(context, listen: false).getCategories();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<AppModel>(
      builder: (context, value, child) {
        if (value.appConfig == null) {
          return kLoadingWidget(context);
        }
        return HomeLayout(configs: value.appConfig);
      },
    );
  }
}
