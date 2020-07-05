import 'package:flutter/material.dart';

import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider_items.dart';
import 'category/category_icon_items.dart';
import 'category/category_image_items.dart';
import 'header/header_text.dart';
import 'logo.dart';
import 'vertical/vertical_layout.dart';
import 'horizontal/horizontal_list_items.dart';
import 'horizontal/slider_list.dart';
import 'horizontal/slider_item.dart';
import 'horizontal/blog_list_layout.dart';

class HomeLayout extends StatefulWidget {
  final configs;

  HomeLayout({this.configs});

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  /// convert the JSON to list of horizontal widgets
  Widget jsonWidget(config) {
    switch (config["layout"]) {
      case "logo":
        return Logo();

      case 'header_text':
//        if (kLayoutWeb) return Container();
        return HeaderText(config: config);


      case "category":
        return (config['type'] == 'image')
            ? CategoryImages(config: config)
            : CategoryIcons(config: config);

      case "bannerAnimated":
        return BannerAnimated(config: config);

      case "bannerImage":
        return config['isSlider'] == true
            ? BannerSliderItems(config: config)
            : BannerGroupItems(config: config);
      case 'largeCardHorizontalListItems':

        return LargeCardHorizontalListItems(
          config: config,
        );
      case "sliderList":
        return HorizontalSliderList(
          config: config,
        );
      case "sliderItem":
        return SliderItem(
          config: config,
        );

      default:
        return BlogListLayout(config: config);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (widget.configs == null) return Container();

    return RefreshIndicator(
      onRefresh: () => Future.delayed(
        Duration(milliseconds: 1000),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            for (var config in widget.configs["HorizonLayout"])
              jsonWidget(
                config,
              ),
            if (widget.configs["VerticalLayout"] != null)
              VerticalViewLayout(
                config: widget.configs["VerticalLayout"],
              ),
          ],
        ),
      ),
    );
  }
}
