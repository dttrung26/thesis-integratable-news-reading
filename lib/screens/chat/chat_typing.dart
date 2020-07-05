import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../common/config.dart' as config;
import '../../common/tools.dart';

final _fireStore = Firestore.instance;

class TypingStream extends StatefulWidget {
  final bool isAdminLoggedIn;
  final String userEmail;

  TypingStream({this.isAdminLoggedIn, this.userEmail});

  @override
  _TypingStreamState createState() => _TypingStreamState();
}

class _TypingStreamState extends State<TypingStream>
    with SingleTickerProviderStateMixin {
  AnimationController controller;
  Animation animation;

  @override
  void initState() {
    controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
//    _setInitTypingValue();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String avatarUserUrl =
        'https://api.adorable.io/avatars/5/${widget.userEmail}.png';
    String avatarAdminUrl =
        'https://api.adorable.io/avatars/5/${config.adminEmail}.png';

    return StreamBuilder(
      stream: _fireStore
          .collection('chatRooms')
          .document(widget.userEmail)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData && (snapshot.data == null)) {
          _fireStore.collection('chatRooms').document(widget.userEmail).setData(
              {'userTyping': false, 'adminTyping': false},
              merge: true);
          return Container();
        }
        var document = snapshot.data;

        if (document == null ||
            document['userTyping'] == null ||
            document['adminTyping'] == null) {
          return Container();
        }

        if (widget.isAdminLoggedIn && document["userTyping"] ||
            !widget.isAdminLoggedIn && document["adminTyping"]) {
          controller.forward();
          return FadeTransition(
            opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
            child: Container(
              padding: EdgeInsets.only(left: 10.0, bottom: 5.0),
              child: Row(
                children: <Widget>[
                  widget.isAdminLoggedIn
                      ? Tools.getCachedAvatar(avatarUserUrl)
                      : Tools.getCachedAvatar(avatarAdminUrl),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'is typing...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).accentColor.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        controller.reset();

        return Container();
      },
    );
  }
}
