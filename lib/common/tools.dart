import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:timeago/timeago.dart' as timeago;
import 'package:validate/validate.dart';

import '../generated/l10n.dart';
import 'config.dart';
import 'constants.dart';

enum kSize { small, medium, large }

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Videos {
  static String getVideoLink(String content) {
    String videoUrl;
    if (_getYoutubeLink(content) != null) {
      videoUrl = _getYoutubeLink(content);
      return videoUrl;
    } else if (_getFacebookLink(content) != null) {
      videoUrl = _getFacebookLink(content);
      return videoUrl;
    } else {
      videoUrl = _getVimeoLink(content);
      return videoUrl;
    }
  }

  static String _getYoutubeLink(String content) {
    final regExp = RegExp(
        "https://www.youtube.com/((v|embed))\/?[a-zA-Z0-9_-]+",
        multiLine: true,
        caseSensitive: false);

    String youtubeUrl;

    try {
      Iterable<RegExpMatch> matches = regExp.allMatches(content);
      youtubeUrl = matches.first.group(0);
    } catch (error) {}
    return youtubeUrl;
  }

  static String _getFacebookLink(String content) {
    final regExp = RegExp(
        "https://www.facebook.com\/[a-zA-Z0-9\.]+\/videos\/(?:[a-zA-Z0-9\.]+\/)?([0-9]+)",
        multiLine: true,
        caseSensitive: false);

    String facebookVideoId;
    String facebookUrl;
    try {
      Iterable<RegExpMatch> matches = regExp.allMatches(content);
      facebookVideoId = matches.first.group(1);
//      print(
//          'facebook regex ${matches.map((m) => facebookVideoId = m.group(1))}');
      if (facebookVideoId != null) {
        facebookUrl =
            'https://www.facebook.com/video/embed?video_id=$facebookVideoId';
      }
    } catch (error) {}
    return facebookUrl;
  }

  static String _getVimeoLink(String content) {
    final regExp = RegExp("https://player.vimeo.com/((v|video))\/?[0-9]+",
        multiLine: true, caseSensitive: false);

    String vimeoUrl;

    try {
      Iterable<RegExpMatch> matches = regExp.allMatches(content);
      vimeoUrl = matches.first.group(0);
//      print('vimeo regex${matches.map((m) => vimeoUrl = m.group(0))}');
    } catch (error) {}
    return vimeoUrl;
  }
}

class Tools {
  static double formatDouble(dynamic value) => value * 1.0;

  static String formatImage(String url, [kSize size = kSize.medium]) {
    if (serverConfig["type"] == "woo" || serverConfig["type"] == null) {
      String pathWithoutExt = p.withoutExtension(url);
      String ext = p.extension(url);
      String imageURL = url ?? kDefaultImage;

      if (ext == ".jpeg") {
        imageURL = url;
      } else {
        switch (size) {
          case kSize.large:
            imageURL = '$pathWithoutExt-large$ext';
            break;
          case kSize.small:
            imageURL = '$pathWithoutExt-small$ext';
            break;
          default: // kSize.medium:e
            imageURL = '$pathWithoutExt-medium$ext';
            break;
        }
      }

      return imageURL;
    } else {
      return url;
    }
  }

  static NetworkImage networkImage(String url, [kSize size = kSize.medium]) {
    return NetworkImage(formatImage(url, size) ?? kDefaultImage);
  }

  static String formatSubstringHtml(String htmlString) {
    print(HtmlUnescape().convert(htmlString));
    return HtmlUnescape().convert(htmlString);
  }

  /// Smart image function to load image cache and check empty URL to return empty box
  /// Only apply for the product image resize with (small, medium, large)
  static image({
    String url,
    kSize size,
    double width,
    double height,
    BoxFit fit,
    String tag,
    double offset = 0.0,
    bool isResize = false,
    isVideo = false,
  }) {
    if (url == null || url == '') {
      return Image.network(
        kDefaultImage,
        width: width,
        height: height,
        color: Color(kEmptyColor),
      );
    }

    if (isVideo) {
      return Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.black12.withOpacity(1)),
            child: ExtendedImage.network(
              isResize ? formatImage(url, size) : url,
              width: width,
              height: height,
              fit: fit,
              cache: true,
              enableLoadState: false,
              alignment: Alignment(
                  (offset >= -1 && offset <= 1)
                      ? offset
                      : (offset > 0) ? 1.0 : -1.0,
                  0.0),
            ),
          ),
          Positioned.fill(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white70.withOpacity(0.5),
              size: 75,
            ),
          ),
        ],
      );
    }

    return ExtendedImage.network(
      isResize ? formatImage(url, size) : url,
      width: width,
      height: height,
      fit: fit,
      cache: true,
      enableLoadState: false,
      alignment: Alignment(
          (offset >= -1 && offset <= 1) ? offset : (offset > 0) ? 1.0 : -1.0,
          0.0),
    );
  }

  static String getCurrecyFormatted(price) {
    Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];
    final formatCurrency = new NumberFormat.currency(
        symbol: "", decimalDigits: defaultCurrency['decimalDigits']);
    try {
      String number = "";
      if (price is String) {
        number =
            formatCurrency.format(price.isNotEmpty ? double.parse(price) : 0);
      } else {
        number = formatCurrency.format(price);
      }
      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + number
          : number + defaultCurrency['symbol'];
    } catch (err) {
      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + formatCurrency.format(0)
          : formatCurrency.format(0) + defaultCurrency['symbol'];
    }
  }

  /// check tablet screen
  static bool isTablet(MediaQueryData query) {
    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  /// cache avatar for the chat
  static getCachedAvatar(String avatarUrl) {
    if (avatarUrl.isEmpty || avatarUrl == '') {
      return CircleAvatar(
        backgroundColor: Color(kEmptyColor),
      );
    } else
      return CachedNetworkImage(
        imageUrl: avatarUrl,
        imageBuilder: (context, imageProvider) => CircleAvatar(
          backgroundImage: imageProvider,
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      );
  }

  static formatDateString(String date, {String locale = 'en'}) {
    DateTime timeFormat = DateTime.parse(date);
    final timeDif = DateTime.now().difference(timeFormat);
    return timeago.format(DateTime.now().subtract(timeDif), locale: locale);
  }

  static String getTime(String time, {context}) {
    var now = new DateTime.now();
    var date = DateTime.parse(time);
    if (now.difference(date).inDays > 0) {
      int timeDifInDay = now.difference(date).inDays;

      if (timeDifInDay < 30) {
        return '$timeDifInDay ${S.of(context).daysAgo}';
      } else if (timeDifInDay < 365) {
        return '${timeDifInDay ~/ 12} ${S.of(context).monthsAgo}';
      } else {
        return '${timeDifInDay ~/ 365} ${S.of(context).yearsAgo}';
      }
    } else if (now.difference(date).inHours > 0) {
      return '${now.difference(date).inHours} ${S.of(context).hoursAgo}';
    } else if (now.difference(date).inMinutes > 0) {
      return '${now.difference(date).inMinutes} ${S.of(context).minutesAgo}';
    } else
      return '${now.difference(date).inSeconds} ${S.of(context).secondsAgo}';
  }
}

class Validator {
  static String validateEmail(String value) {
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }
}

setStatusBarWhiteForeground(bool active) {
  if (kIsWeb == true) {
    return;
  }

  //FlutterStatusbarcolor.setStatusBarWhiteForeground(active);
}
