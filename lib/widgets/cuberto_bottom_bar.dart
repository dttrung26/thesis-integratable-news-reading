library cuberto_bottom_bar;

import 'package:flutter/material.dart';

import '../common/tools.dart';

const double ICON_OFF = -3;
const double ICON_ON = 0;
const double TEXT_OFF = 3;
const double TEXT_ON = 1;
const double ALPHA_OFF = 0;
const double ALPHA_ON = 1;

const double BAR_HEIGHT = 46;
const int ANIM_DURATION = 300;

class TabItem extends StatefulWidget {
  final UniqueKey uniqueKey;
  final String title;
  final dynamic iconData;
  final bool selected;
  final int badge;
  final Function(UniqueKey uniqueKey) callbackFunction;

  final Color textColor;
  final Color iconColor;
  final Color tabColor;
  final double iconYAlign = ICON_ON;
  final double textYAlign = TEXT_OFF;
  final double iconAlpha = ALPHA_ON;
  final GlobalKey stickyKey = GlobalKey();

  TabItem(
      {@required this.uniqueKey,
      @required this.selected,
      @required this.iconData,
      @required this.title,
      @required this.callbackFunction,
      @required this.textColor,
      @required this.iconColor,
      @required this.tabColor,
      this.badge = 0});

  @override
  _TabItemState createState() => _TabItemState();
}

class _TabItemState extends State<TabItem> {
  @override
  Widget build(BuildContext context) {
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        splashColor: Colors.transparent,
        // widget.tabColor.withOpacity(0.4),
        highlightColor: Colors.transparent,
        borderRadius: BorderRadius.circular(3.0),
        onTap: () {
          widget.callbackFunction(widget.uniqueKey);
        },
        child: AnimatedContainer(
          duration: Duration(milliseconds: ANIM_DURATION),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  AnimatedContainer(
                    child: Image.asset(widget.iconData,
                        width: isTablet ? 29 : 22,
                        color: widget.selected
                            ? widget.tabColor
                            : widget.iconColor),
                    padding: EdgeInsets.only(
                        top: 8.0, left: 15.0, right: 10.0, bottom: 10.0),
                    duration: Duration(milliseconds: ANIM_DURATION),
                    decoration: BoxDecoration(
//                      color: widget.selected ? widget.tabColor.withOpacity(0.1) : widget.tabColor.withOpacity(0.3),
                      borderRadius: BorderRadius.all(
                        Radius.circular(3.0),
                      ),
                    ),
                  ),
                  if (widget.badge > 0)
                    Positioned(
                      right: 2,
                      top: 4,
                      child: new Container(
                        padding: EdgeInsets.all(1),
                        decoration: new BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: new Text(
                          widget.badge.toString(),
                          style: new TextStyle(
                            color: Colors.white,
                            fontSize: isTablet ? 14 : 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              ),
              if (widget.title != null)
                AnimatedContainer(
                  duration: Duration(milliseconds: ANIM_DURATION),
                  padding: widget.selected
                      ? EdgeInsets.only(right: 6.0)
                      : EdgeInsets.all(0.0),
                  child: Text(
                    widget.selected ? widget.title : "",
                    overflow: TextOverflow.clip,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color:
                          widget.selected ? widget.tabColor : widget.iconColor,
                      fontWeight: FontWeight.w600,
                      fontSize: isTablet ? 20 : 13,
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class CubertoBottomBar extends StatefulWidget {
  final Function(int position, String title, Color tabColor)
      onTabChangedListener;
  final Color inactiveIconColor;
  final Color tabColor;
  final Color textColor;
  final Color barBackgroundColor;
  final List<TabData> tabs;
  final int initialSelection;
  final CubertoDrawer drawer;
  final CubertoTabStyle tabStyle;

  final Key key;

  CubertoBottomBar(
      {@required this.tabs,
      @required this.onTabChangedListener,
      this.key,
      this.initialSelection = 0,
      this.inactiveIconColor,
      this.textColor,
      this.tabColor,
      this.barBackgroundColor,
      this.drawer,
      this.tabStyle})
      : assert(onTabChangedListener != null),
        assert(tabs != null),
        assert(tabs.length > 1 && tabs.length < 6);

  @override
  CubertoBottomBarState createState() => CubertoBottomBarState();
}

class CubertoBottomBarState extends State<CubertoBottomBar>
    with TickerProviderStateMixin, RouteAware {
  String nextIcon = "assets/icons/tabs/icon-search.png";
  String activeIcon = "assets/icons/tabs/icon-search.png";

  int currentSelected = 0;
  double _circleAlignX = 0;

  Color circleColor;
  Color activeIconColor;
  Color inactiveIconColor;
  Color barBackgroundColor;
  Color textColor;
  Color tabColor;

  CubertoDrawer drawer;
  CubertoTabStyle tabStyle;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    activeIcon = widget.tabs[currentSelected].iconData;
    barBackgroundColor = (widget.barBackgroundColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Color(0xFF212121)
            : Colors.white
        : widget.barBackgroundColor;
    textColor = (widget.textColor == null) ? Colors.white : widget.textColor;
    inactiveIconColor = (widget.inactiveIconColor == null)
        ? (Theme.of(context).brightness == Brightness.dark)
            ? Colors.white
            : Theme.of(context).primaryColor
        : widget.inactiveIconColor;

    tabColor = (widget.tabColor == null) ? activeIconColor : widget.tabColor;
  }

  @override
  void initState() {
    super.initState();
    if (widget.drawer == null) {
      drawer = CubertoDrawer.NO_DRAWER;
    } else {
      drawer = widget.drawer;
    }
    if (widget.tabStyle == null) {
      tabStyle = CubertoTabStyle.STYLE_NORMAL;
    } else {
      tabStyle = widget.tabStyle;
    }
    _setSelected(widget.tabs[widget.initialSelection].key);
  }

  _setSelected(UniqueKey key) {
    int selected = widget.tabs.indexWhere((tabData) => tabData.key == key);

    if (mounted) {
      setState(() {
        currentSelected = selected;
        _circleAlignX = -1 + (2 / (widget.tabs.length - 1) * selected);
        nextIcon = widget.tabs[selected].iconData;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    void _handleDrawerButton() {
      Scaffold.of(context).openDrawer();
    }

    void _handleDrawerButtonEnd() {
      Scaffold.of(context).openEndDrawer();
    }

    Widget actions;
    if (drawer != CubertoDrawer.NO_DRAWER) {
      actions = IconButton(
        icon: Icon(
          Icons.more_vert,
          size: 20,
          color: inactiveIconColor.withAlpha(100),
        ),
        onPressed: widget.drawer == CubertoDrawer.END_DRAWER
            ? _handleDrawerButtonEnd
            : _handleDrawerButton,
        tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
      );
    } else {
      actions = Container();
    }
    return Container(
      color: Theme.of(context).primaryColorLight,
      child: SafeArea(
        child: Stack(
          overflow: Overflow.clip,
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              padding: EdgeInsets.fromLTRB(3.0, 3.0, 3.0, 3.0),
              height: isTablet ? 55 : BAR_HEIGHT,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorLight,
              ),
              child: setUptabs(widget.drawer, widget.tabs,
                  widget.onTabChangedListener, actions),
            ),
          ],
        ),
      ),
    );
  }

  rowTabs(
      List<TabData> tabs,
      Function(int position, String title, Color tabColor)
          onTabChangedListener) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: tabs
          .map((t) => TabItem(
              uniqueKey: t.key,
              selected: t.key == tabs[currentSelected].key,
              iconData: t.iconData,
              title: t.title,
              iconColor: inactiveIconColor,
              textColor: textColor,
              tabColor: t.tabColor == null ? inactiveIconColor : t.tabColor,
              badge: t.badge,
              callbackFunction: (uniqueKey) {
                int selected =
                    tabs.indexWhere((tabData) => tabData.key == uniqueKey);
                onTabChangedListener(selected, t.title, t.tabColor);
                _setSelected(uniqueKey);
                _initAnimationAndStart(_circleAlignX, 1);
              }))
          .toList(),
    );
  }

  setUptabs(
      CubertoDrawer drawer,
      List<TabData> tabs,
      Function(int position, String title, Color tabColor) onTabChangedListener,
      Widget actions) {
    Widget widget;
    if (drawer == CubertoDrawer.END_DRAWER) {
      widget = Row(children: <Widget>[
        Expanded(
          child: rowTabs(tabs, onTabChangedListener),
        ),
        actions,
      ]);
    } else if (drawer == CubertoDrawer.START_DRAWER) {
      widget = Row(children: <Widget>[
        actions,
        Expanded(
          child: rowTabs(tabs, onTabChangedListener),
        ),
      ]);
    } else {
      widget = rowTabs(tabs, onTabChangedListener);
    }
    return widget;
  }

  _initAnimationAndStart(double from, double to) {
    Future.delayed(Duration(milliseconds: ANIM_DURATION ~/ 5), () {
      setState(() {
        activeIcon = nextIcon;
      });
    }).then((_) {
      Future.delayed(Duration(milliseconds: (ANIM_DURATION ~/ 5 * 3)), () {
        setState(() {});
      });
    });
  }
}

class TabData {
  TabData(
      {@required this.iconData,
      @required this.title,
      this.onclick,
      this.tabColor,
      this.badge = 0});

  dynamic iconData;
  String title;
  Function onclick;
  Color tabColor;
  final UniqueKey key = UniqueKey();
  int badge;
}

enum CubertoDrawer { START_DRAWER, END_DRAWER, NO_DRAWER }

enum CubertoTabStyle { STYLE_NORMAL, STYLE_FADED_BACKGROUND }
