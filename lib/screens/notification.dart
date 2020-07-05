import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../generated/l10n.dart';
import '../models/notification.dart';

class Notifications extends StatelessWidget {
  final LocalStorage storage = new LocalStorage('thesiscseiu');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: storage.ready,
      builder: (BuildContext context, snapshot) {
        if (snapshot.data == true) {
          var data = storage.getItem('notifications');

          return NotificationScreen(data: data);
        } else {
          return Container(
            child: Text("Loadding..."),
          );
        }
      },
    );
  }
}

class NotificationScreen extends StatefulWidget {
  final data;

  NotificationScreen({Key key, @required this.data}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final LocalStorage storage = new LocalStorage('thesiscseiu');
  var _data;

  @override
  void initState() {
    super.initState();
    _data = widget.data;
  }

  void callback() {
    setState(() async {
      try {
        final ready = await storage.ready;
        if (ready) {
          var list = storage.getItem('notifications');
          if (list == null) {
            list = [];
          }
          setState(() {
            _data = list;
          });
        }
      } catch (err) {
//        print(err);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).listMessages,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        centerTitle: true,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
      ),
      body: _data == null
          ? Container(
              child: Center(
                child: Text('Empty messages'),
              ),
            )
          : Container(
              color: Theme.of(context).backgroundColor,
              child: ListView.builder(
                itemCount: _data.length,
                itemBuilder: (context, index) {
                  return convert.jsonDecode(_data[index])['date'] == null
                      ? Container()
                      : Padding(
                          child: Dismissible(
                            key: Key(convert
                                .jsonDecode(_data[index])['date']
                                .toString()),
                            onDismissed: (direction) {
                              removeItem(index);
                            },
                            background: Container(color: Colors.redAccent),
                            child: Card(
                              child: ListTile(
                                onTap: () {
                                  _showAlert(context,
                                      convert.jsonDecode(_data[index]), index);
                                },
                                title: Text(
                                  convert
                                      .jsonDecode(_data[index])['title']
                                      .toString(),
                                  style: TextStyle(
                                      color: Theme.of(context).accentColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400),
                                ),
                                subtitle: Column(
                                  children: <Widget>[
                                    Padding(
                                      child: Text(
                                        convert
                                            .jsonDecode(_data[index])['body']
                                            .toString(),
                                        maxLines: 2,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .accentColor
                                              .withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.only(top: 8, bottom: 8),
                                    ),
                                    Text(
                                      getTime(
                                        convert
                                            .jsonDecode(_data[index])['date']
                                            .toString(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context)
                                            .accentColor
                                            .withOpacity(0.5),
                                      ),
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                                leading: Icon(
                                  Icons.notifications_none,
                                  size: 30,
                                  color:
                                      convert.jsonDecode(_data[index])['seen']
                                          ? Colors.grey
                                          : Colors.greenAccent,
                                ),
                                isThreeLine: true,
                              ),
                            ),
                          ),
                          padding:
                              EdgeInsets.only(bottom: 10, left: 10, right: 10),
                        );
                },
              ),
            ),
    );
  }

  String getTime(String time) {
    var now = new DateTime.now();
    var date = DateTime.parse(time);
    if (now.difference(date).inDays > 0) {
      return '${now.difference(date).inDays} ${S.of(context).daysAgo}';
    }
    if (now.difference(date).inHours > 0) {
      return '${now.difference(date).inHours} ${S.of(context).hoursAgo}';
    }
    if (now.difference(date).inMinutes > 0) {
      return '${now.difference(date).inMinutes} ${S.of(context).minutesAgo}';
    }
    return '${now.difference(date).inSeconds} ${S.of(context).secondsAgo}';
  }

  void removeItem(int index) async {
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        if (list == null) {
          list = [];
        }
        list.removeAt(index);
        await storage.setItem('notifications', list);
        setState(() {
          _data = list;
        });
      }
    } catch (err) {
//      print(err);
    }
  }

  void _showAlert(
      BuildContext context, Map<String, dynamic> data, int index) async {
    FStoreNotification a = FStoreNotification.fromLocalStorage(data);
    a.updateSeen(index);
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        if (list == null) {
          list = [];
        }
        setState(() {
          _data = list;
        });
      }
    } catch (err) {
//      print(err);
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Container(
          child: Icon(
            Icons.notifications_none,
            color: Colors.greenAccent,
            size: 40,
          ),
          alignment: Alignment.topLeft,
        ),
        content: Container(
            height: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              children: <Widget>[
                Text(
                  data['title'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20.0),
                Text(
                  data['body'],
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16),
                )
              ],
            )),
      ),
    );
  }
}
