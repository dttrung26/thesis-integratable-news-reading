import 'package:flutter/material.dart';
import 'package:async/async.dart';
import 'package:provider/provider.dart';
import '../../services/wordpress.dart';
import '../../models/blog_news.dart';
import '../../models/user.dart';
import '../../generated/l10n.dart';
import 'post_view.dart';
import 'new_post.dart';

class PostManagementScreen extends StatefulWidget {
  @override
  _PostManagementScreenState createState() => _PostManagementScreenState();
}

class _PostManagementScreenState extends State<PostManagementScreen> {
  final WordPress _service = WordPress();
  Future<List<BlogNews>> _getBlogsByUserId;
  final _memoizer = AsyncMemoizer<List<BlogNews>>();

  @override
  Widget build(BuildContext context) {
    User user = Provider.of<UserModel>(context, listen: false).user;
    Future<List<BlogNews>> getBlogsByUserId(context) => _memoizer.runOnce(
          () => _service.getBlogsByUserId(user.id),
        );

    // only create the future once
    Future.delayed(Duration.zero, () {
      setState(() {
        _getBlogsByUserId = getBlogsByUserId(context);
      });
    });

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(
          S.of(context).postManagement,
          style: TextStyle(color: Theme.of(context).accentColor),
        ),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0,
        leading: Center(
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).accentColor,
            ),
            onTap: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<BlogNews>>(
          future: _getBlogsByUserId,
          builder:
              (BuildContext context, AsyncSnapshot<List<BlogNews>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Scaffold(
                  body: Container(
                    color: Theme.of(context).backgroundColor,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              case ConnectionState.done:
              default:
                if (snapshot.hasError || snapshot.data == null) {
                  return Material(
                    child: Container(
                      alignment: Alignment.center,
                      color: Theme.of(context).backgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 100,
                          ),
                          Image.network(
                            "https://i.pinimg.com/736x/cf/e2/b3/cfe2b376e7c397e935288ebadee60370.jpg",
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                          ),
                          Text(
                            'Error on getting post!',
                            style: TextStyle(color: Colors.black),
                          ),
                          FlatButton(
                            color: Theme.of(context).accentColor,
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: new Text(
                              "Go back to home page",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.data.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Image.network(
                            "https://i.pinimg.com/736x/cf/e2/b3/cfe2b376e7c397e935288ebadee60370.jpg",
                            width: MediaQuery.of(context).size.width,
                            height: 200,
                          ),
                          Text(
                            S.of(context).noPost,
                            style:
                                Theme.of(context).textTheme.bodyText2.copyWith(
                                      fontSize: 20.0,
                                      height: 1.4,
                                      color: Theme.of(context).accentColor,
                                    ),
                            softWrap: true,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Material(
                  color: Theme.of(context).backgroundColor,
                  elevation: 0,
                  child: Scrollbar(
                    controller: ScrollController(),
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (_, index) => PostView(
                        blogs: snapshot.data,
                        index: index,
                      ),
                    ),
                  ),
                );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => NewPostScreen(),
          ));
        },
        icon: Icon(
          Icons.note_add,
          color: Theme.of(context).primaryColorLight,
        ),
        label: Text(
          S.of(context).addNewBlog,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        elevation: 5.0,
        backgroundColor: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16.0),
          ),
        ),
        heroTag: "addNewBlog",
      ),
    );
  }
}
