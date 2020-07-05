import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firestore_ui/firestore_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../common/tools.dart';

final _fireStore = Firestore.instance;

class MessagesStream extends StatefulWidget {
  final bool isAdmin;
  final String userEmail;
  final FirebaseUser user;

  MessagesStream({this.isAdmin, this.userEmail, this.user});

  @override
  _MessagesStreamState createState() => _MessagesStreamState();
}

class _MessagesStreamState extends State<MessagesStream>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollController;
  bool isAtTopOfChatList = true;
  String lastestMessage = '';
  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.offset !=
            _scrollController.position.minScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        isAtTopOfChatList = false;
      });
    } else {
      setState(() {
        isAtTopOfChatList = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reference = _fireStore
        .collection('chatRooms')
        .document(widget.userEmail)
        .collection('chatScreen')
        .orderBy('createdAt', descending: true)
        .snapshots();
    var getLatestMessageQuery = _fireStore
        .collection('chatRooms')
        .where('userEmail', isEqualTo: widget.user.email)
        .limit(1);
    getLatestMessageQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          lastestMessage = data.documents[0].data['lastestMessage'];
        });
      }
    });
    return Expanded(
      child: Column(
//        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Flexible(
            child: FirestoreAnimatedList(
                controller: _scrollController,
                reverse: true,
                query: reference,
                itemBuilder: (context, snapshot, animation, index) {
                  return FadeTransition(
                    opacity: CurvedAnimation(
                        parent: animation, curve: Curves.easeIn),
                    child: MessageBubble(
                      index: index,
                      document: snapshot,
                      isMe: widget.user.email == snapshot.data['sender'],
                      user: widget.user,
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

class ScrollToTopBubble extends StatelessWidget {
  final DocumentSnapshot document;

  ScrollToTopBubble({this.document});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(3.0),
            topRight: Radius.circular(10.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(10.0),
          )),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Text(
          "opps",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.0,
          ),
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final int index;
  final DocumentSnapshot document;
  final bool isMe;
  final FirebaseUser user;

  MessageBubble({this.index, this.document, this.isMe, this.user});

  @override
  Widget build(BuildContext context) {
    DateTime date = DateTime.parse(document.data['createdAt']);
    bool isRecent = DateTime.now().difference(date).inHours < 24;
    var dateFormat = isRecent
        ? DateFormat('h:mm a').format(date)
        : DateFormat('h:mm a - d/M').format(date);

    return Padding(
      padding: const EdgeInsets.only(right: 10.0, left: 10.0),
      child: Row(
        children: isMe
            ? displayMyMessage(context, dateFormat)
            : displaySenderMessage(context, dateFormat),
      ),
    );
  }

  List<Widget> displaySenderMessage(context, dateFormat) {
    var theme = Theme.of(context);
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: Tools.getCachedAvatar(
            'https://api.adorable.io/avatars/60/${document.data['sender']}.png'),
      ),
      Expanded(
        flex: 7,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                dateFormat.toString(),
                style: theme.textTheme.headline5.copyWith(
                    fontSize: 10, color: theme.accentColor.withOpacity(0.5)),
              ),
              SizedBox(
                height: 5.0,
              ),
              document.data['image'] == null
                  ? Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(3.0),
                            topRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(10.0),
                          )),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: Text(
                          "${document.data['text']}",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      child: Tools.image(
                        url: document.data['image'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) {
                            return DetailedImage(
                              imageUrl: document.data['image'],
                            );
                          }),
                        );
                      },
                    )
            ],
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Container(
          width: 0,
          height: 0,
        ),
      )
    ];
  }

  List<Widget> displayMyMessage(context, dateFormat) {
    var theme = Theme.of(context);

    return <Widget>[
      Expanded(
        flex: 3,
        child: Container(
          width: 0,
          height: 0,
        ),
      ),
      Expanded(
        flex: 7,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              //in user chat screen, do not display user email, only display admin email
              Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Text(
                  dateFormat.toString(),
                  style: theme.textTheme.headline5.copyWith(
                      fontSize: 10, color: theme.accentColor.withOpacity(0.5)),
                ),
              ),
              SizedBox(
                height: 5.0,
              ),
              document.data['image'] == null
                  ? Container(
                      decoration: BoxDecoration(
                          color: Theme.of(context).primaryColorLight,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10.0),
                            topRight: Radius.circular(10.0),
                            bottomLeft: Radius.circular(10.0),
                            bottomRight: Radius.circular(3.0),
                          )),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 15.0),
                        child: Text(
                          "${document.data['text']}",
                          style: TextStyle(
                            color: Theme.of(context).accentColor,
                            fontSize: 15.0,
                          ),
                        ),
                      ),
                    )
                  : GestureDetector(
                      child: Tools.image(
                        url: document.data['image'],
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) {
                            return DetailedImage(
                              imageUrl: document.data['image'],
                            );
                          }),
                        );
                      },
                    )
//                  : Tools.image(
//                      url: document.data['image'],
//                      width: 200,
//                      height: 200,
//                      fit: BoxFit.cover)
            ],
          ),
        ),
      ),
    ];
  }
}

class DetailedImage extends StatelessWidget {
  final String imageUrl;

  DetailedImage({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Tools.image(
        url: imageUrl,
        fit: BoxFit.fitWidth,
        height: double.infinity,
        width: double.infinity,
      ),
      backgroundColor: Colors.black,
    );
  }
}
