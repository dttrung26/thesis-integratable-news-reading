import 'dart:ui' as ui show ImageFilter;

import 'package:firebase_admob/firebase_admob.dart';
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

class FullImageType extends StatefulWidget {
  final BlogNews item;

  FullImageType({Key key, @required this.item}) : super(key: key);

  @override
  _FullImageTypeState createState() => _FullImageTypeState();
}

class _FullImageTypeState extends State<FullImageType> {
  ScrollController _scrollController;
  double _opacity = 0;
  BannerAd myBanner;
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

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  _buildChildWidgetAd() {
    if (isFBBannerShown)
      return Ads().facebookBanner();
    else if (isFBNativeBannerAdShown) return Ads().facebookBannerNative();
  }

  _scrollListener() {
    if (_scrollController.offset == 0 && _opacity == 1) {
      setState(() => _opacity = 0);
    } else if (_opacity == 0) {
      setState(() => _opacity = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: MediaQuery.of(context).size.height,
          child: Hero(
            tag: 'blog-${widget.item.id}',
            child: Tools.image(
              url: widget.item.imageFeature,
              fit: BoxFit.fitHeight,
              size: kSize.medium,
            ),
            transitionOnUserGestures: true,
          ),
        ),
        Positioned.fill(
          child: AnimatedOpacity(
            duration: Duration(milliseconds: 600),
            opacity: _opacity,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(
                sigmaX: 15,
                sigmaY: 15,
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
              ),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.black87, Colors.black54, Colors.black45],
                stops: [0.1, 0.3, 0.5],
                begin: Alignment.bottomCenter,
                end: Alignment.center),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: <Widget>[
              Row(
                children: <Widget>[
                  ShareButton(
                    blogSlug: widget.item.slug,
                  ),
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
            leading: IconButton(
                color: Colors.white.withOpacity(0.8),
                icon: Icon(Icons.arrow_back_ios),
                onPressed: Navigator.of(context).pop),
          ),
          body: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.6,
                            left: 15,
                            right: 15,
                            bottom: 15),
                        child: Text(
                          widget.item.title,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 25,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Row(
                        children: <Widget>[
//                          Padding(
//                            padding: EdgeInsets.only(right: 15, left: 15),
//                            child: Tools.getCachedAvatar(
//                                'https://api.adorable.io/avatars/40/${widget.item.author}.png'),
//                          ),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 15),
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
//                                    color: Colors.white,
//                                    fontWeight: FontWeight.w600,
//                                  ),
//                                ),
//                                SizedBox(
//                                  height: 4,
//                                ),
                                  Text(
                                    Tools.formatDateString(widget.item.date),
                                    softWrap: true,
                                    style: TextStyle(
                                      fontSize: 15,
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 6.0),
                        child: HtmlWidget(
                          widget.item.content,
                          hyperlinkColor:
                              Theme.of(context).primaryColor.withOpacity(0.9),
                          textStyle:
                              Theme.of(context).textTheme.bodyText2.copyWith(
                                    fontSize: 14.0,
                                    height: 1.4,
                                    color: Colors.white,
                                  ),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, bottom: 15),
                          child: Column(
                            children: <Widget>[
                              CommentLayout(
                                postId: widget.item.id,
                                type: kCommentLayout.fullSize,
                              ),
                              CommentInput(
                                blogId: widget.item.id,
                              ),
                            ],
                          )),
                      isFBNativeAdShown ? Ads().facebookNative() : Container(),
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
    );
  }
}
