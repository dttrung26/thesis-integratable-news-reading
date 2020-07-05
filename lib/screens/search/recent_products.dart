import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/styles.dart';
import '../../generated/l10n.dart';
import '../../models/search.dart';
import '../../widgets/blog_news/blog_card_view.dart';

class Recent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableProvider.value(
      value: Provider.of<SearchModel>(context, listen: false),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (model.blogs == null || model.blogs.isEmpty) {
          return Container();
        }
        return Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Row(
              children: <Widget>[
                SizedBox(width: 10),
                Expanded(
                  child: Text(S.of(context).recents,
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
//                FlatButton(
//                    onPressed: null,
//                    child: Text(
//                      S.of(context).seeAll,
//                      style: TextStyle(color: Colors.greenAccent, fontSize: 13),
//                    ))
              ],
            ),
            SizedBox(height: 10),
            Divider(
              height: 1,
              color: kGrey200,
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.width * 0.35 + 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var item in model.blogs)
                      BlogCard(
                          item: item,
                          width: MediaQuery.of(context).size.width * 0.35)
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
