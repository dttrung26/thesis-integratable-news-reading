import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/comment.dart';
import '../../../models/user.dart';
import '../../../services/wordpress.dart';

class CommentLayout extends StatefulWidget {
  final int postId;
  final kCommentLayout type;

  CommentLayout({this.postId, this.type});

  @override
  _CommentLayoutState createState() => _CommentLayoutState();
}

class _CommentLayoutState extends State<CommentLayout> {
  List<Comment> comments;
  final comment = TextEditingController();

  void sendComment() {
    final user = Provider.of<UserModel>(context, listen: false);
    final comment = TextEditingController();

    print(widget.postId);
    WordPress().createComment(blogId: widget.postId, data: {
      "content": comment.text,
      "author_name": (user.user.name != null) ? user.user.name : "Guest",
      "author_avatar_urls": user.user.picture != null
          ? user.user.picture
          : 'https://api.adorable.io/avatars/60/${user.user.name != null ? user.user.name : 'guest'}.png',
      "email": user.user.email != null ? user.user.email : null,
      "date": DateTime.now().toIso8601String(),
    }).then((onValue) {
//      getListReviews();
      setState(() {
        comment.text = "";
      });
      final snackBar =
          SnackBar(content: Text(S.of(context).commentSuccessfully));
      Scaffold.of(context).showSnackBar(snackBar);
      return;
    });
  }

  void getListReviews() {
    WordPress().getCommentsByPostId(postId: widget.postId).then((onValue) {
      setState(() {
        comments = onValue;
      });
    });
  }

  @override
  void initState() {
    getListReviews();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'Comment',
            style: widget.type == kCommentLayout.fullSize
                ? TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)
                : TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).accentColor),
          ),
          comments == null
              ? Center(
                  child: Text(
                    "Loading ...",
                    style: widget.type == kCommentLayout.fullSize
                        ? TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8))
                        : TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).accentColor),
                  ),
                )
              : (comments.length == 0
                  ? Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        "Be the first one comment on this news!",
                        style: widget.type == kCommentLayout.fullSize
                            ? TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 15)
                            : TextStyle(
                                color: Theme.of(context).accentColor,
                                fontSize: 15),
                      ),
                    )
                  : Padding(
                      padding: EdgeInsets.only(top: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          for (var comment in comments)
                            CommentBox(
                              comment: comment,
                              type: widget.type,
                            ),
                        ],
                      ),
                    )),
        ],
      ),
    );
  }
}

class CommentBox extends StatelessWidget {
  final Comment comment;
  final kCommentLayout type;

  CommentBox({this.comment, this.type});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Divider(
          height: 1,
          color: Theme.of(context).accentColor.withOpacity(0.2),
        ),
        SizedBox(
          height: 20,
        ),
        Container(
          constraints: BoxConstraints(
            minHeight: 50,
          ),
          width: MediaQuery.of(context).size.width,
          child: Row(
//        crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      CircleAvatar(
                        child: Tools.getCachedAvatar(comment.authorAvatarUrl),
                      ),
                      SizedBox(
                        height: 05,
                      ),
                      Text(
                        comment.authorName,
                        style: type == kCommentLayout.fullSize
                            ? TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              )
                            : TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).accentColor,
                                fontSize: 13,
                              ),
                      )
                    ],
                  )),
              Expanded(
                flex: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 5.0),
                      child: HtmlWidget(
                        comment.content,
                        bodyPadding: EdgeInsets.all(0),
                        hyperlinkColor:
                            Theme.of(context).primaryColor.withOpacity(0.9),
                        textStyle: type == kCommentLayout.fullSize
                            ? Theme.of(context).textTheme.bodyText2.copyWith(
                                  fontSize: 14.0,
                                  color: Colors.white.withOpacity(0.9),
                                  height: 1.3,
                                )
                            : Theme.of(context).textTheme.bodyText2.copyWith(
                                  fontSize: 14.0,
                                  color: Theme.of(context).accentColor,
                                  height: 1.3,
                                ),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      comment.date == '' || comment.date.isEmpty
                          ? 'Loading ...'
                          : Tools.formatDateString(comment.date),
                      style: type == kCommentLayout.fullSize
                          ? TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 12,
                            )
                          : TextStyle(
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.7),
                              fontSize: 12,
                            ),
                      textAlign: TextAlign.right,
                    )
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
