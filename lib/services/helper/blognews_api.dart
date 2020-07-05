import 'dart:async';
import 'dart:convert';
import "dart:core";
import 'dart:io';
import 'package:http/http.dart' as http;

class QueryString {
  static Map parse(String query) {
    var search = new RegExp('([^&=]+)=?([^&]*)');
    var result = new Map();

    // Get rid off the beginning ? in query strings.
    if (query.startsWith('?')) query = query.substring(1);
    // A custom decoder.
    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    // Go through all the matches and build the result map.
    for (Match match in search.allMatches(query)) {
      result[decode(match.group(1))] = decode(match.group(2));
    }
    return result;
  }
}

class BlogNewsApi {
  String url;
  bool isHttps;

  BlogNewsApi(url) {
    this.url = url;

    if (this.url.startsWith("https")) {
      this.isHttps = true;
    } else {
      this.isHttps = false;
    }
  }

  _getOAuthURL(String requestMethod, String endpoint) {
    return this.url + "/wp-json/wp/v2/" + endpoint;
  }

  Future<http.StreamedResponse> getStream(String endPoint) async {
    var client = new http.Client();
    var request = new http.Request('GET', Uri.parse(url));
    return await client.send(request);
  }

  Future<dynamic> getAsync(String endPoint) async {
    var url = this._getOAuthURL("GET", endPoint);

    final response = await http.get(url);
    return json.decode(response.body);
  }

  Future<dynamic> postAsync(String endPoint, Map data) async {
    var url = this._getOAuthURL("POST", endPoint);

    var client = new http.Client();
    var request = new http.Request('POST', Uri.parse(url));
    request.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = "no-cache";
    request.body = json.encode(data);
    var response =
        await client.send(request).then((res) => res.stream.bytesToString());
    print(request.body);
//    await client.post(url, body: request.body).toString();
    var dataResponse = await json.decode(response);
    return dataResponse;
  }

  Future<dynamic> putAsync(String endPoint, Map data) async {
    var url = this._getOAuthURL("PUT", endPoint);

    var client = new http.Client();
    var request = new http.Request('PUT', Uri.parse(url));
    request.headers[HttpHeaders.contentTypeHeader] =
        'application/json; charset=utf-8';
    request.headers[HttpHeaders.cacheControlHeader] = "no-cache";
    request.body = json.encode(data);
    var response =
        await client.send(request).then((res) => res.stream.bytesToString());
    var dataResponse = await json.decode(response);
    return dataResponse;
  }
}
