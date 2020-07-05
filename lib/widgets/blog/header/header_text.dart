import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../widgets/blog/search/custom_search.dart';
import '../../../widgets/blog/search/custom_search_page.dart' as search;
import 'header_type.dart';

class HeaderText extends StatelessWidget {
  final config;

  HeaderText({this.config});

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
      config['height'] != null ? MediaQuery.of(context).size.height * config['height'] : 120,
      padding: EdgeInsets.only(
          top: Tools.formatDouble(config['padding'] ?? 20.0),
          left: Tools.formatDouble(config['padding'] ?? 20.0),
          right: Tools.formatDouble(config['padding'] ?? 15.0),
          bottom: 10.0),
      width: MediaQuery.of(context).size.width,
      child: SafeArea(
        bottom: false,
        top: config['isSafeArea'] == true,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Expanded(child: HeaderType(config: config),),
            if (config['showSearch'] == true)
              IconButton(
                icon: Icon(Icons.search),
                iconSize: 24.0,
                onPressed: () {
                  search.showSearch(context: context, delegate: CustomSearch());
                },
              )
          ],
        ),
      ),
    );
  }
}
