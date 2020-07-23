import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../common/config.dart' as config;
import '../models/user.dart';
import '../screens/chat/chat_screen.dart';
import '../widgets/fab_circle_menu.dart';

class SmartChat extends StatefulWidget {
  final User user;
  final EdgeInsets margin;

  SmartChat({this.user, this.margin});

  @override
  _SmartChatState createState() => _SmartChatState();
}

class _SmartChatState extends State<SmartChat> with WidgetsBindingObserver {
  bool canLaunchAppURL;

  @override
  void initState() {
    super.initState();
    // With this, we will be able to check if the permission is granted or not
    // when returning to the application
    WidgetsBinding.instance.addObserver(this);
  }

  IconButton getIconButton(
      IconData iconData, double iconSize, Color iconColor, String appUrl) {
    return IconButton(
        icon: Icon(
          iconData,
          size: iconSize,
          color: iconColor,
        ),
        onPressed: () async {
          print(appUrl);
          if (await canLaunch(appUrl)) {
            launch(appUrl);
            setState(() {
              setState(() {
                canLaunchAppURL = true;
              });
            });
          } else {
            setState(() {
              canLaunchAppURL = false;
            });
          }
          if (!canLaunchAppURL) {
            final snackBar = SnackBar(
              content: Text(
                  'Cannot launch this app, make sure your settings on config.dart is correct'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  // Some code to undo the change.
                },
              ),
            );
            Scaffold.of(context).showSnackBar(snackBar);
          }
        });
  }

  List<Widget> getFabIconButton() {
    List<Widget> listWidget = [];

    for (int i = 0; i < config.smartChat.length; i++) {
      switch (config.smartChat[i]['app']) {
        default:
          listWidget.add(getIconButton(config.smartChat[i]['iconData'], 35,
              Theme.of(context).primaryColorLight, config.smartChat[i]['app']));
      }
    }
    listWidget.add(
      IconButton(
          icon: Icon(
            FontAwesomeIcons.google,
            size: 35,
            color: Theme.of(context).primaryColorLight,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ChatScreen(
                          user: widget.user,
                          userEmail: widget.user.email,
                        )));
          }),
    );
    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    return FabCircularMenu(
      child: Container(),
      fabOpenIcon: Icon(Icons.chat),
      ringColor: Theme.of(context).primaryColor,
      ringWidth: 125.0,
      ringDiameter: 300.0,
      fabMargin: widget.margin ?? EdgeInsets.only(bottom: 0),
      options: getFabIconButton(),
    );
  }
}
