import 'dart:core';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/category.dart';
import '../../models/user.dart';
import '../../services/wordpress.dart';
import '../../widgets/login_animation.dart';

class NewPostScreen extends StatefulWidget {
  @override
  _NewPostScreenState createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen>
    with TickerProviderStateMixin {
  final titleTextController = TextEditingController();
  final contentTextController = TextEditingController();
  final categoriesTextController = TextEditingController();
  final statusTextController = TextEditingController();
  final WordPress _service = WordPress();
  String content;
  String title;
  int category;
  String status;
  File _image;
  bool isLoading = false;
  AnimationController _submitButtonController;

  @override
  void dispose() {
    titleTextController.dispose();
    contentTextController.dispose();
    categoriesTextController.dispose();
    statusTextController.dispose();
    _submitButtonController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _submitButtonController = new AnimationController(
        duration: new Duration(milliseconds: 3000), vsync: this);
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _submitButtonController.forward();
    } on TickerCanceled {}
  }

  Future<Null> _stopAnimation() async {
    try {
      await _submitButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {}
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text('Warning: $message'),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: "Close",
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  _showSnackBar(String title, context) {
    var snackBar = SnackBar(
      duration: Duration(seconds: 3),
      content: Text(
        "$title",
        style: Theme.of(context).textTheme.bodyText2.copyWith(
            fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    final String locale = Provider.of<AppModel>(context, listen: false).locale;
    final bool isRightToLeftDirectionDetected = locale == 'ar' ? true : false;
    User user = Provider.of<UserModel>(context, listen: false).user;

    _submitPost(context) {
      if (title == null ||
          content == null ||
          category == null ||
          _image == null) {
        _showSnackBar(S.of(context).pleaseInput, context);
      } else {
        _playAnimation();
        _service.createBlog(_image, data: {
          "title": titleTextController.text,
          "content": contentTextController.text,
          "author": user.id,
          "date": DateTime.now().toIso8601String(),
          "status": "draft",
          "categories": category,
        }).whenComplete(() {
          _showSnackBar('Your post has been successfully created', context);
          _stopAnimation().whenComplete(() {
            Navigator.pop(context);
          });
        }).catchError((err) {
          _stopAnimation();
          _failMessage("Fail on creating post with error: $err", context);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).addANewPost,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(height: 20),
                Text(
                  S.of(context).title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: TextField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                      ),
                      textDirection: isRightToLeftDirectionDetected
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      autofocus: true,
                      cursorColor: Theme.of(context).focusColor,
                      style: Theme.of(context).textTheme.bodyText2.copyWith(
                            fontSize: 14.0,
                            height: 1.4,
                            color: Theme.of(context).accentColor,
                          ),
                      controller: titleTextController,
                      onChanged: (text) {
                        setState(() {
                          title = text;
                        });
                      }),
                ),
                SizedBox(height: 20),
                Text(
                  S.of(context).content,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                Container(
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: Theme.of(context).primaryColorLight,
                  ),
                  child: TextField(
                    maxLines: 50,
                    minLines: 6,
                    textAlign: TextAlign.justify,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                    ),
                    textDirection: isRightToLeftDirectionDetected
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    autofocus: true,
                    cursorColor: Theme.of(context).focusColor,
                    style: Theme.of(context).textTheme.bodyText2.copyWith(
                          fontSize: 14.0,
                          height: 1.4,
                          color: Theme.of(context).accentColor,
                        ),
                    controller: contentTextController,
                    onChanged: (text) {
                      setState(() {
                        content = text;
                      });
                    },
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  S.of(context).category,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 10),
                if (categories != null && categories.length > 0)
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Theme.of(context).primaryColorLight,
                    ),
                    child: DropdownButton<String>(
                      value: category != null ? category.toString() : category,
                      icon: Icon(Icons.arrow_drop_down),
                      isExpanded: true,
                      onChanged: (text) {
                        setState(() {
                          category = int.parse(text);
                        });
                      },
                      underline: Container(),
                      items: List.generate(categories.length, (index) {
                        return DropdownMenuItem(
                          value: '${categories[index].id}',
                          child: Text('${categories[index].name}'),
                        );
                      }),
                    ),
                  ),
                SizedBox(height: 20),
                Text(
                  S.of(context).imageFeature,
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      .copyWith(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 15,
                ),
                Center(
                  child: _image == null
                      ? Container(
                          constraints: BoxConstraints(
                            minHeight: 80,
                            maxHeight: 100,
                          ),
                          height: 50.0,
                          child: RawMaterialButton(
                            onPressed: () => getImage(),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add_a_photo,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(2),
                            ),
                            elevation: 0.1,
                            fillColor: Theme.of(context).primaryColorLight,
                          ),
                        )
                      : Image.file(
                          _image,
                          width: MediaQuery.of(context).size.width - 40,
                          fit: BoxFit.cover,
                        ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Builder(
                    builder: (context) => StaggerAnimation(
                      titleButton: S.of(context).submit,
                      buttonController: _submitButtonController.view,
                      onTap: () {
                        if (!isLoading) {
                          _submitPost(context);
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  height: 100,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
