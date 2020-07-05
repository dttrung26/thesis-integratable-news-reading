import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart' as config;
import 'chat_list_by_admin.dart';
import '../login.dart';
import 'chat_screen.dart';
import '../../models/user.dart';

class ChatTab extends StatefulWidget {
  @override
  _ChatTabState createState() => _ChatTabState();
}

class _ChatTabState extends State<ChatTab> {
  @override
  Widget build(BuildContext context) {
    final userModel = Provider.of<UserModel>(context, listen: false);

    return ListenableProvider.value (
        value: userModel,
        child: Consumer<UserModel>(builder: (context, value, child) {
          if (value.user != null) {
            if (value.user.email == config.adminEmail) {
              return ListChat(
                user: value.user,
              );
            }
            return ChatScreen(
              user: value.user,
              userEmail: value.user.email,
            );
          }
          return LoginScreen();
        }));
  }
}
