import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../widgets/blog/search/custom_search.dart';
import '../../../widgets/blog/search/custom_search_page.dart' as search;
import '../../../models/app.dart';
import '../../../common/tools.dart';

class HeaderSearch extends StatelessWidget {
  final config;

  HeaderSearch({this.config});

  @override
  Widget build(BuildContext context) {
    final locale = Provider.of<AppModel>(context, listen: false).locale;
    final text = config["text"] != null ? config["text"][locale] : '';

    return Container(
      padding: EdgeInsets.all(Tools.formatDouble(config['padding'] ?? 20.0)),
      width: MediaQuery.of(context).size.width,
      height: Tools.formatDouble(config['height'] ?? 85.0),
      child: SafeArea(
        bottom: false,
        top: config['isSafeArea'] == true,
        child: InkWell(
          onTap: () {
            search.showSearch(context: context, delegate: CustomSearch());
          },
          child: Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, size: 24),
                SizedBox(
                  width: 12.0,
                ),
                Text(text)
              ],
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: Tools.formatDouble(config['shadow'] ?? 15.0),
                  offset: Offset(0, Tools.formatDouble(config['shadow'] ?? 10.0)),
                ),
              ],
              borderRadius: BorderRadius.circular(30.0),
              border: Border.all(
                width: 1.0,
                color: Colors.black.withOpacity(0.05),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
