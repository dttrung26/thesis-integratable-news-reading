import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';

class HeaderView extends StatelessWidget {
  final String headerText;
  final VoidCallback callback;
  final bool showSeeAll;

  HeaderView({this.headerText, this.showSeeAll = false, Key key, this.callback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 15.0, top: 40.0, right: 15.0, bottom: 15.0),
      child: Row(
        textBaseline: TextBaseline.alphabetic,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        children: <Widget>[
          Expanded(
            child: Text(
              this.headerText ?? '',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (showSeeAll)
            InkResponse(
              onTap: callback,
              child: Text(
                S.of(context).seeAll,
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Theme.of(context).primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
