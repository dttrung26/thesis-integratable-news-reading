import 'dart:convert';

import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Blog {
  final int id;
  final String title;
  final String subTitle;
  final String date;
  final String content;
  final String author;
  final String imageFeature;

  Blog(
      {this.id,
      this.content,
      this.author,
      this.date,
      this.title,
      this.subTitle,
      this.imageFeature});

  factory Blog.fromJson(Map<String, dynamic> json) {
    var imageFeature = json['better_featured_image'] != null
        ? json['better_featured_image']['media_details']['sizes']['medium']['source_url']
        : null;
    if (imageFeature == null) {
      imageFeature = json['_embedded']['wp:featuredmedia'] != null
          ? json['_embedded']['wp:featuredmedia'][0]['media_details']["sizes"]["large"]
              ["source_url"]
          : '';
    }

    String author = json["_embedded"]["author"][0]["name"];

    DateTime date = DateTime.parse(json['date']);
    String dateString = DateFormat.yMMMMd("en_US").format(date);

    String subString = HtmlUnescape().convert(json['excerpt']['rendered']);

    return Blog(
      id: json['id'],
      title: HtmlUnescape().convert(json['title']['rendered']),
      content: json['content']['rendered'],
      subTitle: subString,
      author: author,
      date: dateString,
      imageFeature: imageFeature,
    );
  }

  Blog.empty(int id)
      : this.id = id,
        title = '',
        subTitle = '',
        date = '',
        author = '',
        content = '',
        imageFeature = '';

  static Future<dynamic> getBlogs({url, page = 1}) async {
    final response = await http.get("$url/wp-json/wp/v2/posts?_embed&page=$page");
    return json.decode(response.body);
  }

  @override
  String toString() => 'Blog { id: $id  title: $title}';
}
