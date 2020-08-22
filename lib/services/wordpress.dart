import 'dart:async';
import 'dart:convert' as convert;
import "dart:core";
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:quiver/strings.dart';

import '../models/blog_news.dart';
import '../models/category.dart';
import '../models/comment.dart';
import '../models/user.dart';
import 'helper/blognews_api.dart';

class WordPress {
  WordPress serviceApi;
  static final WordPress _instance = WordPress._internal();

  factory WordPress() => _instance;

  WordPress._internal();

  static BlogNewsApi blogApi;

  String isSecure;

  String url;

  void setAppConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig["url"]);
    isSecure = appConfig["url"].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig["url"];
  }

  Future<Null> createComment({int blogId, Map<String, dynamic> data}) async {
    try {
      await blogApi.postAsync("comments?post=$blogId", data);
    } catch (e) {
      throw e;
    }
  }

  Future<List<BlogNews>> searchBlog({name}) async {
    try {
      var response = await blogApi.getAsync("posts?_embed&search=$name");

      List<BlogNews> list = [];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      print(list);
      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<String> getJwtAuth(String username, String password) async {
    try {
      var endPoint =
          "$url/wp-json/jwt-auth/v1/token?username=$username&password=$password";
      var response = await http.post(endPoint);
      var jsonDecode = convert.jsonDecode(response.body);
      if (jsonDecode['token'] == null) {
        throw Exception(jsonDecode['code']);
      }
      return jsonDecode['token'];
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document or contact supporters/
      throw e;
    }
  }

  Future<Null> createBlog(File file, {Map<String, dynamic> data}) async {
    try {
      int mediaImageId;
      String jwtToken = await UserModel().getJwtAuthToken();
      if (jwtToken == null) {
        print('Error on getting JwtToken');
      } else {
        await blogApi.uploadImage(file, jwtToken).then((response) {
          mediaImageId = response['id'];
          if (mediaImageId != null) {
            data['featured_media'] = mediaImageId;
          }
        });
        await blogApi.postAsync("posts", data, token: jwtToken);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<List<BlogNews>> getBlogsByUserId(int userId) async {
    try {
      var response = await blogApi.getAsync("posts?_embed&author=$userId");
      List<BlogNews> list = [];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<List<Comment>> getCommentsByPostId({postId}) async {
    try {
      print(postId);
      List<Comment> list = [];

      var endPoint = "comments?";
      if (postId != null) {
        endPoint += "&post=$postId";
      }

      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        list.add(Comment.fromJson(item));
      }

      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<List<Category>> getCategories({lang = "en"}) async {
    try {
      var response = await blogApi.getAsync("categories?per_page=20");
      List<Category> list = [];
      for (var item in response) {
        list.add(Category.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<List<BlogNews>> getBlogs() async {
    try {
      var response = await blogApi.getAsync("posts");
      List<BlogNews> list = [];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<BlogNews> getBlog(id) async {
    try {
      var response = await blogApi.getAsync("posts/$id");

      return BlogNews.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  Future<List<BlogNews>> fetchBlogLayout({config, lang = 'en'}) async {
    try {
      List<BlogNews> list = [];

      var endPoint = "posts?_embed&per_page=10&lang=$lang";
      if (config.containsKey("category")) {
        endPoint += "&categories=${config["category"]}";
      }

      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        BlogNews blog = BlogNews.fromJson(item);
        blog.categoryId = config["category"];
        list.add(blog);
      }

      return list;
    } catch (e) {
      throw e;
    }
  }

  Future<List<BlogNews>> fetchBlogsByCategory({categoryId, page, lang}) async {
    try {
      print(categoryId);
      List<BlogNews> list = [];

      var endPoint = "posts?_embed&lang=$lang&per_page=15&page=$page";
      if (categoryId != null) {
        endPoint += "&categories=$categoryId";
      }
      var response = await blogApi.getAsync(endPoint);
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }

      return list;
    } catch (e) {
      throw e;
    }
  }

  Future getNonce({method = 'register'}) async {
    try {
      http.Response response = await http.get(
          "$url/api/get_nonce/?controller=mstore_user&method=$method&$isSecure");
      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body)['nonce'];
      } else {
        throw Exception(['error getNonce', response.statusCode]);
      }
    } catch (e) {
      throw e;
    }
  }

  Future<User> loginGoogle({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          "$url/wp-json/api/flutter_user/google_login/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode["cookie"] == null) {
        throw Exception(jsonDecode['error']);
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document/
      throw e;
    }
  }

  Future<User> loginApple({String email, String fullName}) async {
    try {
      var endPoint =
          "$url/wp-json/api/flutter_user/apple_login?email=$email&display_name=$fullName&user_name=${email.split("@")[0]}$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document

      throw e;
    }
  }

  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint =
          "$url/wp-json/api/flutter_user/fb_connect/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['wp_user_id'] == null || jsonDecode["cookie"] == null) {
        throw Exception(jsonDecode['msg']);
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document

      throw e;
    }
  }

  Future<User> loginSMS({String token}) async {
    try {
      //var endPoint = "$url/wp-json/api/flutter_user/sms_login/?access_token=$token$isSecure";
      var endPoint =
          "$url/wp-json/api/flutter_user/firebase_sms_login?phone=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document

      throw e;
    }
  }

  Future<User> getUserInfo(cookie, {password}) async {
    try {
      final http.Response response = await http.get(
          "$url/wp-json/api/flutter_user/get_currentuserinfo?cookie=$cookie&$isSecure");
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["user"] != null) {
        var user = body['user'];
        user['password'] = password;
        return User.fromAuthUser(user, cookie);
      } else {
        throw Exception(body["message"]);
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document f

      throw err;
    }
  }

  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      String niceName = firstName + " " + lastName;

      final http.Response response = await http.post(
          "$url/wp-json/api/flutter_user/register/?insecure=cool&$isSecure",
          body: convert.jsonEncode({
            "user_email": username,
            "user_login": username,
            "username": username,
            "user_pass": password,
            "email": username,
            "user_nicename": niceName,
            "display_name": niceName,
          }));

      var body = convert.jsonDecode(response.body);
      print(body);

      if (response.statusCode == 200 && body["message"] == null) {
        var cookie = body['cookie'];
        return await this.getUserInfo(cookie, password: password);
      } else {
        var message = body["message"];
        throw Exception(message != null ? message : "Can not create the user.");
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document
      print(err.toString());
      throw err;
    }
  }

  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      final http.Response response = await http.post(
          "$url/wp-json/api/flutter_user/generate_auth_cookie/?insecure=cool&$isSecure",
          body: convert.jsonEncode({
            "seconds": cookieLifeTime.toString(),
            "username": username,
            "password": password
          }));

      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && isNotBlank(body['cookie'])) {
        return await this.getUserInfo(body['cookie'], password: password);
      } else {
        throw Exception("The username or password is incorrect.");
      }
    } catch (err) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document
      throw err;
    }
  }
}
