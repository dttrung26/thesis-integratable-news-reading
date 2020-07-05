import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/advertisement.dart';
import '../../../models/blog_news.dart';
import '../../../widgets/heart_button.dart';
import '../../../widgets/share_button.dart';
import '../comments/comment_text_field.dart';
import '../comments/comments.dart';

class OneQuarterImageType extends StatefulWidget {
  final BlogNews item;

  OneQuarterImageType({Key key, @required this.item}) : super(key: key);

  @override
  _OneQuarterImageTypeState createState() => _OneQuarterImageTypeState();
}

class _OneQuarterImageTypeState extends State<OneQuarterImageType>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  ScrollController _scrollController;
  bool isExpandedListView = true;
  bool isShownComment = false;
  bool isFBNativeBannerAdShown = false;
  bool isFBNativeAdShown = false;
  bool isFBBannerShown = false;
  bool isVideoDetected = false;

  String videoUrl;
  Key key = UniqueKey();

  @override
  void dispose() {
    Ads.hideBanner();
    Ads.hideInterstitialAd();
    super.dispose();
  }

  @override
  void initState() {
    if (Videos.getVideoLink(widget.item.content) != null) {
      setState(() {
        videoUrl = Videos.getVideoLink(widget.item.content);

        isVideoDetected = true;
      });
    } else {
      isVideoDetected = false;
    }

    Ads.googleAdInit();

    if (kAdConfig['type'] == kAdType.facebookBanner ||
        kAdConfig['type'] == kAdType.facebookNative ||
        kAdConfig['type'] == kAdType.facebookInterstitial ||
        kAdConfig['type'] == kAdType.facebookNativeBanner) Ads.facebookAdInit();

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
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _scrollListener() {
    if (_scrollController.offset == 0) {
      setState(() {
        isExpandedListView = true;
      });
    } else {
      setState(() {
        isExpandedListView = false;
      });
    }
  }

  _buildChildWidgetAd() {
    if (isFBBannerShown)
      return Ads().facebookBanner();
    else if (isFBNativeBannerAdShown) return Ads().facebookBannerNative();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Column(
              children: <Widget>[
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    child: ListView(
                      controller: _scrollController,
                      children: <Widget>[
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 3,
                                width: MediaQuery.of(context).size.width - 20,
                                child: Center(
                                  child: Stack(
                                    children: <Widget>[
                                      Hero(
                                        tag: 'blog-${widget.item.id}',
                                        child: Tools.image(
                                          url: widget.item.imageFeature,
                                          fit: BoxFit.cover,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          size: kSize.large,
                                        ),
                                        transitionOnUserGestures: true,
                                      ),
                                      isVideoDetected
                                          ? WebView(
                                              key: key,
                                              initialUrl: videoUrl,
                                              javascriptMode:
                                                  JavascriptMode.unrestricted,
                                            )
                                          : Tools.image(
                                              url: widget.item.imageFeature,
                                              fit: BoxFit.cover,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  3,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              size: kSize.large,
                                            ),
                                      Positioned(
                                        top: 0,
                                        right: 45,
                                        child: ShareButton(
                                          blogSlug: widget.item.slug,
                                        ),
                                      ),
                                      Positioned(
                                        top: 10,
                                        right: 10,
                                        child: HeartButton(
                                          size: 18,
                                          isTransparent: true,
                                          blog: widget.item,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: 15, left: 15, right: 15, bottom: 5),
                          child: Text(
                            widget.item.title,
                            softWrap: true,
                            style: TextStyle(
                              fontSize: 25,
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.8),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        HtmlWidget(
                          widget.item.content,
                          hyperlinkColor:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          textStyle:
                              Theme.of(context).textTheme.bodyText2.copyWith(
                                    fontSize: 13.0,
                                    height: 1.4,
                                    color: Theme.of(context).accentColor,
                                  ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 15),
                          child: Column(
                            children: <Widget>[
                              CommentLayout(
                                postId: widget.item.id,
                                type: kCommentLayout.oneQuarter,
                              ),
                              CommentInput(
                                blogId: widget.item.id,
                              ),
                            ],
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
            Positioned(
              bottom: 50,
              left: 90,
              child: AnimatedOpacity(
                opacity: isExpandedListView ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width - 180,
                  child: Card(
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
//                          Padding(
//                            padding: EdgeInsets.only(right: 15),
//                            child: Tools.getCachedAvatar(
//                                'https://api.adorable.io/avatars/60/${widget.item.author}.png'),
//                          ),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
//                                Text(
//                                  'by ${widget.item.author} ',
//                                  softWrap: false,
//                                  maxLines: 1,
//                                  overflow: TextOverflow.ellipsis,
//                                  style: TextStyle(
//                                    fontSize: 14,
//                                    color: Theme.of(context)
//                                        .accentColor
//                                        .withOpacity(0.45),
//                                    fontWeight: FontWeight.w600,
//                                  ),
//                                ),
                                Text(
                                  Tools.formatDateString(widget.item.date),
                                  softWrap: true,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context).accentColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 5,
              child: GestureDetector(
                onTap: () {
                  try {
                    Ads.hideBanner();
                  } catch (error) {
                    print(error);
                  }

                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.all(12.0),
                  padding: EdgeInsets.all(8.0),
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
            Container(
              alignment: Alignment.bottomCenter,
              child: _buildChildWidgetAd(),
            )
          ],
        ),
      ),
    );
  }
}
