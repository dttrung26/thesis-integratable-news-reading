import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import '../../common/tools.dart';
import '../../models/blog_news.dart';
import '../../widgets/blog/detailed_blog/blog_view.dart';

class PostView extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;
  final double width;
  final String type;
  final double imageBorder;
  final String locale;
  final context;
  PostView(
      {this.blogs,
      this.index,
      this.width,
      this.type,
      this.imageBorder = 4,
      this.context,
      this.locale = 'en'});

  @override
  Widget build(BuildContext context) {
    double imageWidth = (width == null) ? 150 : width;
    double titleFontSize = imageWidth / 10;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => getDetailPageView(blogs.sublist(index)),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(imageBorder),
                ),
                child: Tools.image(
                  url: blogs[index].imageFeature,
                  width: imageWidth,
                  height: imageWidth,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      blogs[index].title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).accentColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(
                      height: imageWidth / 35,
                    ),
                    Text(
                      blogs[index].date == ''
                          ? 'Loading ...'
                          : Tools.getTime(blogs[index].date, context: context),
                      style: TextStyle(
                        color: Theme.of(context).accentColor,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    blogs[index].excerpt == "Loading..."
                        ? Text(blogs[index].excerpt)
                        : Text(
                            parse(blogs[index].excerpt).documentElement.text,
                            maxLines: 3,
                            style: Theme.of(context)
                                .textTheme
                                .bodyText2
                                .copyWith(
                                    fontSize: 13.0,
                                    height: 1.4,
                                    color: Theme.of(context).accentColor),
                          ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
