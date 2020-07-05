import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import '../../screens/chat/chat_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../models/user.dart';

final _fireStore = Firestore.instance;

class ListChat extends StatefulWidget {
  final User user;

  ListChat({this.user});

  @override
  _ListChatState createState() => _ListChatState();
}

class _ListChatState extends State<ListChat> {
  final bannerHigh = 200.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Chat List Screen",
          style: TextStyle(color: kLightPrimary),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: Padding(
        padding: EdgeInsets.all(15.0),
        child: ChatItemsStream(),
      ),
    );
  }
}

class ChatItemsStream extends StatefulWidget {
  @override
  _ChatItemsStreamState createState() => _ChatItemsStreamState();
}

class _ChatItemsStreamState extends State<ChatItemsStream> {
  final reference = _fireStore
      .collection('chatRooms')
      .orderBy('createdAt', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      child: Container(
        child: FirestoreAnimatedList(
            query: reference,
            itemBuilder: (context, snapshot, animation, index) {
              return SizeTransition(
                sizeFactor:
                    CurvedAnimation(parent: animation, curve: Curves.easeIn),
                child: ChatItem(
                  index: index,
                  document: snapshot,
                ),
              );
            }),
      ),
    );
  }
}

class ChatItem extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;

  ChatItem({this.index, this.document});

  @override
  Widget build(BuildContext context) {
    final timeDif =
        DateTime.now().difference(DateTime.parse(document.data['createdAt']));
    return GestureDetector(
        onTap: () {
          _fireStore
              .collection('chatRooms')
              .document(document['userEmail'])
              .updateData({
            'isSeenByAdmin': true,
            'userTyping': false,
            'adminTyping': false
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChatScreen(userEmail: document['userEmail'], isAdmin: true),
            ),
          );
        },
        child: Padding(
          padding: EdgeInsets.only(bottom: 10.0),
          child: Card(
            color: Theme.of(context).bottomAppBarColor,
            elevation: 1.5,
            child: ListTile(
              contentPadding:
                  EdgeInsets.only(top: 10, bottom: 10, left: 20.0, right: 10.0),
              leading: Tools.getCachedAvatar(
                  'https://api.adorable.io/avatars/100/${document['userEmail']}.png'),
              title: Row(
                children: <Widget>[
                  Expanded(
                    flex: 7,
                    child: Text(
                      document['userEmail'],
                      style: kProductTitleStyleLarge.copyWith(fontSize: 15.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      '${timeago.format(DateTime.now().subtract(timeDif), locale: 'en')}',
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontStyle: FontStyle.italic, fontSize: 10.0),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              subtitle: document['userTyping']
                  ? Text(
                      '${document['userEmail'].toString().split('@').first} is typing ...',
                      style: DefaultTextStyle.of(context).style.copyWith(
                          fontStyle: FontStyle.italic, fontSize: 12.0),
                      overflow: TextOverflow.fade,
                    )
                  : Text(
                      '${document['lastestMessage']}',
                      style: DefaultTextStyle.of(context).style,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
              dense: true,
              enabled: document['isSeenByAdmin'],
            ),
          ),
        ));
  }
}
