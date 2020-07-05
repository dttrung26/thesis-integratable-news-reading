import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../models/blog_news.dart';
import '../widgets/blog/blog_list_view.dart';

class BlogScreen extends StatefulWidget {
  final List<BlogNews> blogs;

  BlogScreen({this.blogs});

  @override
  State<StatefulWidget> createState() {
    return BlogScreenState();
  }
}

class BlogScreenState extends State<BlogScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.1,
        title: Text(
          S.of(context).blog,
          style: TextStyle(color: Colors.white),
        ),
        leading: Center(
          child: GestureDetector(
            onTap: () => {Navigator.pop(context)},
            child: Icon(Icons.arrow_back_ios, color: Colors.white),
          ),
        ),
      ),
      body: SafeArea(
        child: BlogListView(blogs: widget.blogs),
      ),
    );
  }
}
