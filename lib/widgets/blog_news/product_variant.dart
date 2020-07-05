import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/styles.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';

enum VariantLayout { inline, dropdown }

class BasicSelection extends StatelessWidget {
  final List<String> options;
  final String value;
  final String title;
  final String type;
  final Function onChanged;
  final VariantLayout layout;

  BasicSelection(
      {@required this.options,
      @required this.title,
      @required this.value,
      this.type,
      this.layout,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    if (type == "option")
      return OptionSelection(
          options: options, value: value, title: title, onChanged: onChanged);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  child: Text(
                    "${title[0].toUpperCase()}${title.substring(1)}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  padding: EdgeInsets.only(bottom: 10),
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 0.0,
            runSpacing: 12.0,
            children: <Widget>[
              for (var item in options)
                Container(
                  //height: type == "color" ? 26 : 30,
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeIn,
                    margin: EdgeInsets.only(right: 15.0),
                    decoration: type == "color"
                        ? BoxDecoration(
                            color: item == value
                                ? HexColor(
                                    kColorNameToHex[item.toLowerCase()] ??
                                        "#ffffff")
                                : HexColor(
                                        kColorNameToHex[item.toLowerCase()] ??
                                            "#ffffff")
                                    .withOpacity(0.6),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                width: 1.0,
                                color: Theme.of(context)
                                    .accentColor
                                    .withOpacity(0.3)),
                          )
                        : BoxDecoration(
                            color: item == value
                                ? primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              color: Theme.of(context)
                                  .accentColor
                                  .withOpacity(0.3),
                            ),
                          ),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        onChanged(item);
                      },
                      child: type == "color"
                          ? SizedBox(
                              height: 25,
                              width: 25,
                              child: item == value
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 16,
                                    )
                                  : Container(),
                            )
                          : Container(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: Padding(
                                child: Text(
                                  item,
                                  style: TextStyle(
                                    color: item == value
                                        ? Colors.white
                                        : Theme.of(context).accentColor,
                                    fontSize: 14,
                                  ),
                                ),
                                padding: EdgeInsets.only(top: 5, bottom: 5),
                              ),
                            ),
                    ),
                  ),
                )
            ],
          ),
        ]);
  }
}

class OptionSelection extends StatelessWidget {
  final List<String> options;
  final String value;
  final String title;
  final Function onChanged;
  final VariantLayout layout;

  OptionSelection(
      {@required this.options,
      @required this.value,
      this.title,
      this.layout,
      this.onChanged});

  showOptions(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final option in options)
                ListTile(
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                    },
                    title: Text(option, textAlign: TextAlign.center)),
              Container(
                height: 1,
                decoration: BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheSize,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showOptions(context),
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
        height: 42,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Text("${title[0].toUpperCase()}${title.substring(1)}",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Theme.of(context).accentColor,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 5),
              Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
            ],
          ),
        ),
      ),
    );
  }
}

class ColorSelection extends StatelessWidget {
  final List<String> options;
  final String value;
  final Function onChanged;
  final VariantLayout layout;

  ColorSelection(
      {@required this.options,
      @required this.value,
      this.layout,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (layout == VariantLayout.dropdown) {
      return GestureDetector(
        onTap: () => showOptions(context),
        child: Container(
          decoration:
              BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
          height: 42,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(S.of(context).color,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ),
                Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        color: kColorNameToHex[value.toLowerCase()] != null
                            ? HexColor(kColorNameToHex[value.toLowerCase()])
                            : Colors.transparent)),
                SizedBox(width: 5),
                Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 25,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Center(
              child: Text(
                S.of(context).color,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            SizedBox(
              width: 15.0,
            ),
            for (var item in options)
              AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  margin: EdgeInsets.only(right: 20.0),
                  decoration: BoxDecoration(
                    color: item == value
                        ? HexColor(kColorNameToHex[item.toLowerCase()])
                        : HexColor(kColorNameToHex[item.toLowerCase()])
                            .withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20.0),
                    border: Border.all(
                        width: 1.0,
                        color: Theme.of(context).accentColor.withOpacity(0.5)),
                  ),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      onChanged(item);
                    },
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: item == value
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : Container(),
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  void showOptions(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final option in options)
                ListTile(
                  onTap: () {
                    onChanged(option);
                    Navigator.pop(context);
                  },
                  title: Center(
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        border: Border.all(
                            width: 1.0, color: Theme.of(context).accentColor),
                        color: HexColor(kColorNameToHex[option.toLowerCase()]),
                      ),
                    ),
                  ),
                ),
              Container(
                height: 1,
                decoration: BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheColor,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }
}

class QuantitySelection extends StatelessWidget {
  final List<int> defaultOptions = [1, 2, 3, 4, 5, 6];
  final int value;
  final double width;
  final double height;
  final Function onChanged;
  final Color color;

  QuantitySelection(
      {@required this.value,
      this.width = 80.0,
      this.height = 42.0,
      @required this.color,
      this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onChanged != null) {
          showOptions(context);
        }
      },
      child: Container(
        decoration:
            BoxDecoration(border: Border.all(width: 1.0, color: kGrey200)),
        height: height,
        width: width,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Center(
                  child: Text(
                    value.toString(),
                    style: TextStyle(fontSize: 14, color: color),
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, size: 16, color: kGrey600)
            ],
          ),
        ),
      ),
    );
  }

  void showOptions(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (final option in defaultOptions)
                ListTile(
                    onTap: () {
                      onChanged(option);
                      Navigator.pop(context);
                    },
                    title: Text(
                      option.toString(),
                      textAlign: TextAlign.center,
                    )),
              Container(
                height: 1,
                decoration: BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).selectTheQuantity,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }
}
