import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../generated/l10n.dart';
import '../../../models/user.dart';
import '../../../services/wordpress.dart';

class CommentInput extends StatefulWidget {
  final int blogId;

  CommentInput({this.blogId});
  @override
  _CommentInputState createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final comment = TextEditingController();
  void sendComment() {
    final user = Provider.of<UserModel>(context, listen: false);

    print(widget.blogId);

    WordPress().createComment(blogId: widget.blogId, data: {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 40, top: 15.0),
      padding: EdgeInsets.only(left: 15.0, bottom: 15.0, top: 5.0),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight,
        borderRadius: BorderRadius.circular(3.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: TextField(
              controller: comment,
              maxLines: 2,
              decoration: InputDecoration(hintText: "Comment something"),
            ),
          ),
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Icons.send,
                color: Theme.of(context).primaryColor,
              ),
            ),
            onTap: () {
              sendComment();
            },
          )
        ],
      ),
    );
  }
}
