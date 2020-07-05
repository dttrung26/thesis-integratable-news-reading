import 'package:flutter/material.dart';

import 'banner_items.dart';

/// The Banner Group type to display the image as multi columns
class BannerGroupItems extends StatelessWidget {
  final config;

  BannerGroupItems({this.config});

  @override
  Widget build(BuildContext context) {
    List items = config['items'];

    return Padding(
      padding: EdgeInsets.all(config['padding'] ?? 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: BannerImageItem(
                config: items[i],
              ),
            ),
        ],
      ),
    );
  }
}
