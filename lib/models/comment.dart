import 'package:flutter/material.dart';
import '../services/wordpress.dart';

class CommentModel with ChangeNotifier {
  List<Comment> comments;
  Map<int, Comment> commentList = {};

  bool isLoading = true;
  String message;
//

  void getCommentsByPostId({postId}) async {
    try {
      comments = await WordPress().getCommentsByPostId(postId: postId);
      isLoading = false;

      for (Comment cmt in comments) {
        commentList[cmt.id] = cmt;
      }

      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
    }
  }
}

class Comment {
  int id;
  int postId;
  String authorName;
  String authorAvatarUrl;
  String date;
  String content;
//
//  Comment.test() {
//    id = 1112;
//    postId = 1112;
//    authorName = 'asd';
//    date = DateTime.now().toString();
//    content = 'Test2611';
//    authorAvatarUrl = 'Test';
//  }

  Comment.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    postId = parsedJson["post"];
    authorName = parsedJson["author_name"];
    authorAvatarUrl = parsedJson["author_avatar_urls"]["96"];
    date = parsedJson["date"];
    content = parsedJson["content"]["rendered"];
  }

  Comment.empty(int id) {
    this.id = id;
    authorName = 'Loading...';
    date = '';
    content = 'Loading';
    authorAvatarUrl = '';
  }

  Map<String, dynamic> toJson(Comment comment) {
    return {
      "id": comment.id,
      "post": comment.postId,
      "author_name": comment.authorName,
      "date": comment.date,
      "content": comment.content,
      "author_avatar_urls": comment.authorAvatarUrl,
    };
  }

  @override
  String toString() => 'Comment to String { id: $id  content: $content}';
}
