import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/advertisement.dart';
import '../../../models/blog_news.dart';
import '../../../widgets/heart_button.dart';
import '../../../widgets/share_button.dart';
import '../comments/comment_text_field.dart';
import '../comments/comments.dart';

class HalfImageType extends StatefulWidget {
  final BlogNews item;

  HalfImageType({Key key, @required this.item}) : super(key: key);

  @override
  _HalfImageTypeState createState() => _HalfImageTypeState();
}

class _HalfImageTypeState extends State<HalfImageType> {
  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;

  @override
  void dispose() {
    Ads.hideBanner();
    Ads.hideInterstitialAd();
    super.dispose();
  }

  @override
  void initState() {
    Ads.googleAdInit();
    Ads.facebookAdInit();

    switch (kAdConfig['type']) {
      case kAdType.googleBanner:
        {
          Ads.createBannerAd();
          Ads.showBanner();
          break;
        }
      case kAdType.googleInterstitial:
        {
          Ads.createInterstitialAd();
          Ads.showInterstitialAd();
          break;
        }
      case kAdType.googleReward:
        {
          Ads.showRewardedVideoAd();
          break;
        }
      case kAdType.facebookBanner:
        {
          setState(() {
            isFBBannerShown = true;
          });
          break;
        }
      case kAdType.facebookNative:
        {
          setState(() {
            isFBNativeAdShown = true;
          });
          break;
        }
      case kAdType.facebookNativeBanner:
        {
          setState(() {
            isFBNativeBannerAdShown = true;
          });
          break;
        }
      case kAdType.facebookInterstitial:
        {
          Ads.showFacebookInterstitialAd();
          break;
        }
    }
    super.initState();
  }

  _buildChildWidgetAd() {
    if (isFBBannerShown)
      return Ads().facebookBanner();
    else if (isFBNativeBannerAdShown) return Ads().facebookBannerNative();
  }

  @override
  Widget build(BuildContext context) {
    print('item date ${Tools.formatDateString(widget.item.date)}');
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
              height: MediaQuery.of(context).size.height * 0.7,
              width: MediaQuery.of(context).size.width,
              child: Hero(
                tag: 'blog-${widget.item.id}',
                child: Tools.image(
                  url: widget.item.imageFeature,
                  fit: BoxFit.fitHeight,
                  size: kSize.medium,
                ),
                transitionOnUserGestures: true,
              )),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              actions: <Widget>[
                ShareButton(
                  blogSlug: widget.item.slug,
                ),
                Row(
                  children: <Widget>[
                    HeartButton(
                      size: 16,
                      isTransparent: true,
                      blog: widget.item,
                    ),
                    SizedBox(
                      width: 10,
                    )
                  ],
                )
              ],
              leading: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  margin: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 18.0,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ),
            body: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(35.0),
                                topRight: Radius.circular(35.0),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 15.0,
                                right: 15.0,
                                bottom: 15.0,
                                top: 30.0,
                              ),
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    widget.item.title,
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 25,
                                      color: Theme.of(context).accentColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Row(
                                    children: <Widget>[
//                                Padding(
//                                  padding: EdgeInsets.only(right: 15, left: 15),
//                                  child: Tools.getCachedAvatar(
//                                      'https://api.adorable.io/avatars/40/${widget.item.author}.png'),
//                                ),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            SizedBox(
                                              height: 10,
                                            ),
//                                            Text(
//                                              'by ${widget.item.author} ',
//                                              softWrap: false,
//                                              maxLines: 1,
//                                              overflow: TextOverflow.ellipsis,
//                                              style: TextStyle(
//                                                fontSize: 14,
//                                                color: Theme.of(context)
//                                                    .accentColor,
//                                                fontWeight: FontWeight.w600,
//                                              ),
//                                            ),
//                                            SizedBox(
//                                              height: 10,
//                                            ),
                                            Text(
                                              Tools.formatDateString(
                                                  widget.item.date),
                                              softWrap: true,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .accentColor
                                                    .withOpacity(0.7),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                  HtmlWidget(
                                    widget.item.content,
                                    bodyPadding: EdgeInsets.only(top: 10),
                                    hyperlinkColor: Theme.of(context)
                                        .primaryColor
                                        .withOpacity(0.9),
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .bodyText2
                                        .copyWith(
                                          fontSize: 14.0,
                                          height: 1.4,
                                          color: Theme.of(context).accentColor,
                                        ),
                                  ),
                                  CommentLayout(
                                    postId: widget.item.id,
                                    type: kCommentLayout.halfSize,
                                  ),
                                  CommentInput(
                                    blogId: widget.item.id,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        isFBNativeAdShown
                            ? Ads().facebookNative()
                            : Container(),
                        SizedBox(
                          height: 100,
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomCenter,
            child: _buildChildWidgetAd(),
          )
        ],
      ),
    );
  }
}
