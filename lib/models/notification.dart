import 'package:localstorage/localstorage.dart';
import 'dart:convert' as convert;

class FStoreNotification {
  String body;
  String title;
  bool seen;
  String date;

  FStoreNotification.fromJsonFirebase(Map<String, dynamic> json) {
    try {
      var notification = json['data'] ?? json['notification'];
      body = notification['body'];
      title = notification['title'];
      seen = false;
      date = (new DateTime.now()).toString();
      print(date);
    } catch (e) {
      print(e.toString());
    }
  }

  FStoreNotification.fromJsonFirebaseLocal(Map<String, dynamic> json) {
    try {
      var notification = json['data'] ?? json['notification'];
      body = notification['body'];
      title = notification['title'];
      seen = false;
      int time = notification['google.sent_time'] ?? ['from'];
      date = (new DateTime.fromMillisecondsSinceEpoch(time)).toString();
      print(date);
    } catch (e) {
      print(e.toString());
    }
  }

  FStoreNotification.fromLocalStorage(Map<String, dynamic> json) {
    try {
      body = json['body'];
      title = json['title'];
      date = (DateTime.parse(json['date'])).toString();
      seen = false;
    } catch (e) {
      print(e.toString());
    }
  }

  FStoreNotification.from(String b, String t) {
    body = b;
    title = t;
    seen = false;
  }

  Map<String, dynamic> toJson() => {'body': body, 'title': title, 'seen': seen, 'date': date,};

  void updateSeen(int index) async {
    final LocalStorage storage = new LocalStorage("fstore");
    this.seen = true;
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        if (list == null) {
          list = [];
        }
        list[index] = convert.jsonEncode(this.toJson());
        await storage.setItem('notifications', list);
      }
    } catch (err) {
      print(err);
    }
  }

  void saveToLocal(String id) async {
    final LocalStorage storage = new LocalStorage("fstore");
    
    try {
      final ready = await storage.ready;
      if (ready) {
        var list = storage.getItem('notifications');
        String old = storage.getItem('message-id').toString();
        if(old.isNotEmpty && id != 'null') {
          if (old == id) return;
          await storage.setItem('message-id', id);
        } else {
          await storage.setItem('message-id', id);
        }
        if (list == null) {
          list = [];
        }
        list.insert(0, convert.jsonEncode(this.toJson()));
        await storage.setItem('notifications', list);
      }
    } catch (err) {
      print(err);
    }
  }
}
