import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/search.dart';
import 'recent_products.dart';

class RecentSearches extends StatelessWidget {
  final Function onTap;

  RecentSearches({this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final widthContent = (screenSize.width / 2) - 4;

    return ListenableProvider.value(
      value: Provider.of<SearchModel>(context, listen: false),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        return Column(
          children: <Widget>[
            model.keywords.isEmpty
                ? renderEmpty()
                : renderKeywords(model, widthContent, context)
          ],
        );
      }),
    );
  }

  Widget renderEmpty() {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/images/empty_search.png',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 10),
          Container(
              width: 250,
              child: Text(
                "You haven't searched for items yet. Let's start now - we'll help you.",
                style: TextStyle(color: kGrey400),
                textAlign: TextAlign.center,
              ))
        ],
      ),
    );
  }

  Widget renderKeywords(
      SearchModel model, double widthContent, BuildContext context) {
    return Expanded(
      child: ListView(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: Container(
              height: 45,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(3.0),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(S.of(context).recentSearches),
                  if (model.keywords.isNotEmpty)
                    InkWell(
                        onTap: () {
                          Provider.of<SearchModel>(context, listen: false)
                              .clearKeywords();
                        },
                        child: Text(S.of(context).clear,
                            style:
                                TextStyle(color: Colors.green, fontSize: 13)))
                ],
              ),
            ),
          ),
          Card(
            color: Theme.of(context).primaryColorLight,
            child: Column(
              children: List.generate(
                  (model.keywords.length < 5) ? model.keywords.length : 5,
                  (index) {
                return ListTile(
                    title: Text(model.keywords[index]),
                    onTap: () {
                      onTap(model.keywords[index]);
                    });
              }),
            ),
          ),
          Recent(),
        ],
      ),
    );
  }
}
