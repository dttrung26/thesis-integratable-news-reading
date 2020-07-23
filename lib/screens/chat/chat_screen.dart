import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:place_picker/uuid.dart';
import 'package:thesiscseiu/models/user.dart';

import '../../common/config.dart' as config;
import '../../common/styles.dart';
import 'chat_typing.dart';
import 'messages.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser;

class ChatScreen extends StatefulWidget {
  final User user;
  final String adminEmail = config.adminEmail;
  final String userEmail;
  final bool isAdmin;

  ChatScreen({this.user, this.userEmail, this.isAdmin = false});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _auth = FirebaseAuth.instance;
  final messageTextController = TextEditingController();
  var uuid = new Uuid();
  String messagesText = '';
  File imageFile;
  String imageUrl;

  @override
  void initState() {
//    getCurrentUser();
    super.initState();
    Future.delayed(Duration.zero, () {
      getCurrentUser();
    });
  }

  Future getImage() async {
    imageFile = await ImagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 500, maxWidth: 500);

    if (imageFile != null) {
      uploadFile();
    }
  }

  Future uploadFile() async {
    String fileName = uuid.generateV4();
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
      imageUrl = downloadUrl;
      print(imageUrl);
      if (widget.isAdmin) {
        _fireStore
            .collection('chatRooms')
            .document(widget.userEmail)
            .collection('chatScreen')
            .add({
          'text': '',
          'sender': widget.adminEmail,
          'createdAt': DateTime.now().toString(),
          'image': imageUrl,
        });
        _fireStore.collection('chatRooms').document(widget.userEmail).setData({
          'userTyping': false,
          'adminTyping': false,
          'lastestMessage': 'Admin has sent an image.',
          'userEmail': widget.userEmail,
          'createdAt': DateTime.now().toIso8601String(),
          'isSeenByAdmin': true,
        }, merge: true);
      } else {
        _fireStore
            .collection('chatRooms')
            .document(loggedInUser.email)
            .collection('chatScreen')
            .add({
          'text': '',
          'sender': loggedInUser.email,
          'createdAt': DateTime.now().toString(),
          'image': imageUrl
        });
        _fireStore
            .collection('chatRooms')
            .document(loggedInUser.email)
            .setData({
          'userTyping': false,
          'adminTyping': false,
          'lastestMessage': '${loggedInUser.email} has sent an image',
          'userEmail': loggedInUser.email,
          'createdAt': DateTime.now().toIso8601String(),
          'isSeenByAdmin': false,
        }, merge: true);
      }
    });
  }

  getCurrentUser() async {
    try {
      final user = await _auth.currentUser();

      if (user != null && mounted) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  updateTyping(bool status) {
    String user = widget.isAdmin ? widget.userEmail : loggedInUser.email;
    var document = _fireStore.collection('chatRooms').document(user);

    if (loggedInUser.email == widget.adminEmail)
      document.updateData({'adminTyping': status});
    else
      document.updateData({'userTyping': status});
  }

  @override
  Widget build(BuildContext context) {
//    if (loggedInUser == null) {
//      Provider.of<UserModel>(context).logout();
//      Navigator.of(context).pushNamed('/login');
//      return Container(
//        color: Theme.of(context).backgroundColor,
//        child: kLoadingWidget(context),
//      );
//    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {
            if (Navigator.canPop(context))
              Navigator.of(context).pop();
            else
              Navigator.pushNamed(context, '/home');
          },
        ),
        title: widget.isAdmin
            ? Text(
                '${widget.userEmail}',
                style: TextStyle(color: Colors.white),
              )
            : Text('Contact with supporter',
                style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(
                isAdmin: widget.isAdmin,
                userEmail:
                    widget.isAdmin ? widget.userEmail : loggedInUser.email,
                user: loggedInUser,
              ),
              TypingStream(
                isAdminLoggedIn: loggedInUser.email == widget.adminEmail,
                userEmail:
                    widget.isAdmin ? widget.userEmail : loggedInUser.email,
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.image,
                        color: kTeal100,
                      ),
                      onPressed: () {
                        getImage();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        onChanged: (value) {
                          messagesText = value;
                          updateTyping(true);
                        },
                        onEditingComplete: () {
                          updateTyping(false);
                        },
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () {
                        messageTextController.clear();
                        if (messagesText.isNotEmpty) {
                          //deal with database if admin is true
                          if (widget.isAdmin) {
                            _fireStore
                                .collection('chatRooms')
                                .document(widget.userEmail)
                                .collection('chatScreen')
                                .add({
                              'text': messagesText,
                              'sender': widget.adminEmail,
                              'createdAt': DateTime.now().toString(),
                            });

                            _fireStore
                                .collection('chatRooms')
                                .document(widget.userEmail)
                                .setData({
                              'adminTyping': false,
                              'lastestMessage': messagesText,
                              'userEmail': widget.userEmail,
                              'createdAt': DateTime.now().toIso8601String(),
                              'isSeenByAdmin': true,
                              'userTyping': false,
                              'adminTyping': false,
                              'image': ''
                            }, merge: true);
                          } else {
                            //else treat as normal user
                            _fireStore
                                .collection('chatRooms')
                                .document(loggedInUser.email)
                                .collection('chatScreen')
                                .add({
                              'text': messagesText,
                              'sender': loggedInUser.email,
                              'createdAt': DateTime.now().toString(),
                            });
                            _fireStore
                                .collection('chatRooms')
                                .document(loggedInUser.email)
                                .setData({
                              'lastestMessage': messagesText,
                              'userTyping': false,
                              'userEmail': loggedInUser.email,
                              'createdAt': DateTime.now().toIso8601String(),
                              'isSeenByAdmin': false,
                              'userTyping': false,
                              'adminTyping': false,
                              'image': ''
                            }, merge: true);
                          }
                        }
                        messagesText = '';
                      },
                      child: Text(
                        'Send',
                        style: kSendButtonTextStyle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
