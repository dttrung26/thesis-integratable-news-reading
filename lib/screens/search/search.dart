import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/search.dart';
import 'blog_list.dart';
import 'recent_search.dart';

class SearchScreen extends StatefulWidget {
  final isModal;

  SearchScreen({this.isModal});

  @override
  _StateSearchScreen createState() => _StateSearchScreen();
}

class _StateSearchScreen extends State<SearchScreen> {
  bool isVisibleSearch = false;
  String searchText;
  var textController = new TextEditingController();
  Timer _timer;
  FocusNode _focus;

  @override
  void initState() {
    super.initState();
    _focus = new FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() {
      isVisibleSearch = _focus.hasFocus;
    });
  }

  Widget _renderSearchLayout() {
    return ListenableProvider.value(
      value: Provider.of<SearchModel>(context, listen: false),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (searchText == null || searchText.isEmpty) {
          return Padding(
            child: RecentSearches(
              onTap: (text) {
                setState(() {
                  searchText = text;
                });
                textController.text = text;
                FocusScope.of(context)
                    .requestFocus(new FocusNode()); //dismiss keyboard
                Provider.of<SearchModel>(context, listen: false)
                    .searchBlogs(name: text);
              },
            ),
            padding: EdgeInsets.only(left: 10, right: 10),
          );
        }

        if (model.loading) {
          return kLoadingWidget(context);
        }

        if (model.errMsg != null && model.errMsg.isNotEmpty) {
          return Center(
              child: Text(model.errMsg, style: TextStyle(color: kErrorRed)));
        }

        if (model.blogs.length == 0) {
          return Center(child: Text(S.of(context).noProduct));
        }

        return Column(
          children: <Widget>[
            Container(
              height: 45,
              decoration: BoxDecoration(color: HexColor("#F9F9F9")),
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Row(children: [
                Text(
                  S.of(context).weFoundBlogs,
//                  S.of(context).weFoundBlogs(model.blogs.length.toString()),
                )
              ]),
            ),
            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).backgroundColor),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  child: BlogList(name: searchText, blogs: model.blogs),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isModal != null
          ? AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.arrow_back_ios,
                  size: 22,
                ),
              ),
              title: Text(
                S.of(context).search,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            )
          : null,
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            widget.isModal == null
                ? AnimatedContainer(
                    height: isVisibleSearch ? 0 : 40,
                    padding: EdgeInsets.only(left: 15, top: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Text(S.of(context).search,
                            style: TextStyle(
                                fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    duration: Duration(milliseconds: 250),
                  )
                : SizedBox(
                    height: 10.0,
                  ),
            SizedBox(
              height: 10.0,
            ),
            Row(children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColorLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  margin: EdgeInsets.only(left: 10, right: 10, bottom: 15),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.search,
                        color: Colors.black45,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          focusNode: _focus,
                          onChanged: (text) {
                            if (_timer != null) {
                              _timer.cancel();
                            }
                            _timer = Timer(Duration(milliseconds: 500), () {
                              setState(() {
                                searchText = text;
                              });
                              Provider.of<SearchModel>(context, listen: false)
                                  .searchBlogs(name: text);
                            });
                          },
                          decoration: InputDecoration(
                            fillColor: Theme.of(context).accentColor,
                            border: InputBorder.none,
                            hintText: S.of(context).searchForItems,
                          ),
                        ),
                      ),
                      AnimatedContainer(
                        width:
                            (searchText == null || searchText.isEmpty) ? 0 : 50,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              searchText = "";
                              isVisibleSearch = false;
                            });
                            textController.text = "";
                            FocusScope.of(context)
                                .requestFocus(new FocusNode());
                          },
                          child: Center(
                            child: Text(S.of(context).cancel,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        duration: Duration(milliseconds: 200),
                      )
                    ],
                  ),
                ),
              ),
            ]),
            Expanded(child: _renderSearchLayout()),
          ],
        ),
      ),
    );
  }
}
