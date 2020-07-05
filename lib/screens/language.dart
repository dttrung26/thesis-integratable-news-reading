import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../generated/l10n.dart';
import '../models/app.dart';

class Language extends StatefulWidget {
  @override
  _LanguageState createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).language,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        leading: Center(
          child: GestureDetector(
            child: Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: Column(
        children: <Widget>[
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset(
                'assets/images/country/gb.png',
                width: 30,
                height: 20,
                fit: BoxFit.cover,
              ),
              title: Text(S.of(context).english),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('en', context);
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset('assets/images/country/vn.png',
                  width: 30, height: 20, fit: BoxFit.cover),
              title: Text(S.of(context).vietnamese),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('vi', context);
              },
            ),
          ),
          Divider(
            color: Colors.black12,
            height: 1.0,
            indent: 75,
            //endIndent: 20,
          ),
          Card(
            elevation: 0,
            margin: EdgeInsets.all(0),
            child: ListTile(
              leading: Image.asset('assets/images/country/ae.png',
                  width: 30, height: 20, fit: BoxFit.cover),
              title: Text(S.of(context).arabic),
              onTap: () {
                Provider.of<AppModel>(context, listen: false)
                    .changeLanguage('ar', context);
              },
            ),
          )
        ],
      ),
    );
  }
}
