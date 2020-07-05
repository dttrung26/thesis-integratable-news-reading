import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:page_indicator/page_indicator.dart';
import 'banner_items.dart';
import '../header/header_text.dart';

/// The Banner Group type to display the image as multi columns
class BannerSliderItems extends StatefulWidget {
  final config;

  BannerSliderItems({this.config});

  @override
  _StateBannerSlider createState() => _StateBannerSlider();
}

class _StateBannerSlider extends State<BannerSliderItems> {
  int position = 0;

  Widget getBannerPageView() {
    final screenSize = MediaQuery.of(context).size;
    PageController _controller = PageController();
    List items = widget.config['items'];

    return Padding(
      child: PageIndicatorContainer(
        child: PageView(
          controller: _controller,
          onPageChanged: (index) {
            this.setState(() {
              position = index;
            });
          },
          children: <Widget>[
            for (int i = 0; i < items.length; i++)
              BannerImageItem(
                config: items[i],
                width: screenSize.width,
                boxFit: BoxFit.cover,
                padding: widget.config['padding'] ?? 0.0,
                radius: widget.config['radius'] ?? 6.0,
              ),
          ],
        ),
        align: IndicatorAlign.bottom,
        length: items.length,
        indicatorSpace: 5.0,
        padding: const EdgeInsets.all(10.0),
        indicatorColor: Colors.black12,
        indicatorSelectorColor: Colors.black87,
        shape: IndicatorShape.roundRectangleShape(
          size: Size(25.0, 2.0),
        ),
      ),
      padding: EdgeInsets.only(top: 20, bottom: 5),
    );
  }

  Widget renderBanner() {
    List items = widget.config['items'];
    final screenSize = MediaQuery.of(context).size;
    switch (widget.config['design']) {
      case 'swiper':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: screenSize.width,
              boxFit: BoxFit.cover,
              radius: widget.config['radius'] ?? 6.0,
            );
          },
          itemCount: items.length,
          viewportFraction: 0.85,
          scale: 0.9,
        );
      case 'tinder':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: screenSize.width,
              boxFit: BoxFit.cover,
              radius: widget.config['radius'] ?? 6.0,
            );
          },
          itemCount: items.length,
          itemWidth: screenSize.width,
          itemHeight: screenSize.width * 1.2,
          layout: SwiperLayout.TINDER,
        );
      case 'stack':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: screenSize.width,
              boxFit: BoxFit.cover,
              radius: widget.config['radius'] ?? 6.0,
            );
          },
          itemCount: items.length,
          itemWidth: screenSize.width - 40,
          layout: SwiperLayout.STACK,
        );
      case 'custom':
        return Swiper(
          itemBuilder: (BuildContext context, int index) {
            return BannerImageItem(
              config: items[index],
              width: screenSize.width,
              boxFit: BoxFit.cover,
              radius: widget.config['radius'] ?? 6.0,
            );
          },
          itemCount: items.length,
          itemWidth: screenSize.width - 40,
          itemHeight: screenSize.width + 100,
          layout: SwiperLayout.CUSTOM,
          customLayoutOption:
              new CustomLayoutOption(startIndex: -1, stateCount: 3)
                  .addRotate([-45.0 / 180, 0.0, 45.0 / 180]).addTranslate([
            new Offset(-370.0, -40.0),
            new Offset(0.0, 0.0),
            new Offset(370.0, -40.0)
          ]),
        );
      default:
        return getBannerPageView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double _bannerPercent = widget.config['height'] ?? 0.25;
    bool isBlur = widget.config['isBlur'] == true;

    List items = widget.config['items'];
    double bannerExtraHeight =
        screenSize.height * (widget.config['title'] != null ? 0.12 : 0.0);
    double upHeight = widget.config['upHeight'] ?? 0.0;

    return Container(
        height:
            screenSize.height * _bannerPercent + bannerExtraHeight + upHeight,
        child: Stack(
          children: <Widget>[
            if (widget.config['showBackground'] == true)
              Container(
                height: screenSize.height * _bannerPercent +
                    bannerExtraHeight +
                    upHeight,
                child: Padding(
                  child: ClipRRect(
                    child: Stack(children: <Widget>[
                      isBlur
                          ? Transform.scale(
                              child: Image.network(
                                items[position]['background'] != null
                                    ? items[position]['background']
                                    : items[position]['image'],
                                fit: BoxFit.fill,
                                width: screenSize.width + upHeight,
                              ),
                              scale: 3,
                            )
                          : Image.network(
                              items[position]['background'] != null
                                  ? items[position]['background']
                                  : items[position]['image'],
                              fit: BoxFit.fill,
                              width: screenSize.width,
                              height: screenSize.height * _bannerPercent +
                                  bannerExtraHeight +
                                  upHeight,
                            ),
                      ClipRect(
                        child: BackdropFilter(
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  Colors.white.withOpacity(isBlur ? 0.6 : 0.0),
                            ),
                          ),
                          filter: ImageFilter.blur(
                              sigmaX: isBlur ? 12 : 0, sigmaY: isBlur ? 12 : 0),
                        ),
                      ),
                    ]),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.elliptical(100, 6),
                    ),
                  ),
                  padding: EdgeInsets.only(bottom: 50),
                ),
              ),
            if (widget.config['title'] != null)
              HeaderText(
                config: widget.config,
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: screenSize.height * _bannerPercent,
                child: renderBanner(),
              ),
            ),
          ],
        ));
  }
}
