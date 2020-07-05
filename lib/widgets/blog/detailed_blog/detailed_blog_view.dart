import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../common/tools.dart';
import '../../../models/blog_news.dart';

class BlogDetail extends StatefulWidget {
  final BlogNews item;

  BlogDetail({Key key, @required this.item}) : super(key: key);

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogDetail> {
  @override
  Widget build(BuildContext context) {
    BlogNews item = widget.item;
    final bannerHigh = 180.0;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            leading: Center(
              child: GestureDetector(
                onTap: () => {Navigator.pop(context)},
                child:
                    Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
              ),
            ),
            expandedHeight: bannerHigh,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: <Widget>[
                  Hero(
                    tag: 'blog-${item.id}',
                    child: Tools.image(
                        url: item.imageFeature,
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width,
                        size: kSize.medium),
                    transitionOnUserGestures: true,
                  ),
                  Tools.image(
                      url: item.imageFeature,
                      fit: BoxFit.contain,
                      size: kSize.large),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          item.title,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 25,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              item.date,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'by ${item.author}',
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      HtmlWidget(
                        item.content,
                        hyperlinkColor:
                            Theme.of(context).primaryColor.withOpacity(0.9),
                        textStyle:
                            Theme.of(context).textTheme.bodyText2.copyWith(
                                  fontSize: 13.0,
                                  height: 1.4,
                                  color: Theme.of(context)
                                      .accentColor
                                      .withOpacity(0.9),
                                ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
