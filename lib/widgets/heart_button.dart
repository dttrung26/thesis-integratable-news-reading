import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../models/blog_news.dart';
import '../models/wishlist.dart';

class HeartButton extends StatefulWidget {
  final BlogNews blog;
  final double size;
  final type = kAdvanceConfig['HeartButtonType'];
  final isTransparent;

  HeartButton({this.blog, this.size = 15, this.isTransparent = false});

  @override
  _HeartButtonState createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton> {
  @override
  Widget build(BuildContext context) {
    List<BlogNews> wishlist = Provider.of<WishListModel>(context, listen: false).getWishList();
    final isExist = wishlist.firstWhere((item) => item.id == widget.blog.id,
        orElse: () => null);
    final isSquareType = widget.type == kHeartButtonType.squareType;

    if (isExist == null) {
      return isSquareType
          ? AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height: widget.isTransparent
                  ? 30 * (widget.size / 19)
                  : 30 * (widget.size / 15),
              width: widget.isTransparent
                  ? 30 * (widget.size / 19)
                  : 30 * (widget.size / 15),
              decoration: BoxDecoration(
                color: widget.isTransparent
                    ? Colors.transparent
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                onPressed: () {
                  Provider.of<WishListModel>(context, listen: false)
                      .addToWishlist(widget.blog);
                  setState(() {});
                },
                icon: Icon(FontAwesomeIcons.heart,
                    color: Colors.white.withOpacity(0.6),
                    size: widget.size ?? 15.0),
              ),
            )
          : AnimatedContainer(
              duration: Duration(milliseconds: 300),
              height:
                  widget.isTransparent ? widget.size + 17 : widget.size + 10,
              width: widget.isTransparent ? widget.size + 17 : widget.size + 10,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor.withOpacity(0.5),
                borderRadius: widget.isTransparent
                    ? BorderRadius.all(
                        Radius.circular(25),
                      )
                    : BorderRadius.only(bottomLeft: Radius.circular(15)),
              ),
              child: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                onPressed: () {
                  Provider.of<WishListModel>(context, listen: false)
                      .addToWishlist(widget.blog);
                  setState(() {});
                },
                icon: Icon(FontAwesomeIcons.heart,
                    color: Colors.white70, size: widget.size ?? 15.0),
              ),
            );
    }

    return isSquareType
        ? AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: widget.isTransparent
                ? 30 * (widget.size / 19)
                : 30 * (widget.size / 15),
            width: widget.isTransparent
                ? 30 * (widget.size / 19)
                : 30 * (widget.size / 15),
            decoration: BoxDecoration(
              color: widget.isTransparent
                  ? Colors.transparent
                  : Colors.white.withOpacity(0.4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(5),
              ),
            ),
            child: IconButton(
                padding: EdgeInsets.all(0),
                alignment: Alignment.center,
                onPressed: () {
                  Provider.of<WishListModel>(context, listen: false)
                      .removeToWishlist(widget.blog);
                  setState(() {});
                },
                icon: Icon(
                  FontAwesomeIcons.solidHeart,
                  color: Color(kRedColorHeart).withOpacity(0.7),
                  size: widget.size ?? 15.0,
                )),
          )
        : AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: widget.isTransparent ? widget.size + 17 : widget.size + 5,
            width: widget.isTransparent ? widget.size + 17 : widget.size + 5,
            decoration: BoxDecoration(
              color: widget.isTransparent
                  ? Colors.transparent
                  : Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.all(0),
              alignment:
                  widget.isTransparent ? Alignment.center : Alignment.topRight,
              onPressed: () {
                Provider.of<WishListModel>(context, listen: false)
                    .removeToWishlist(widget.blog);
                setState(() {});
              },
              icon: Icon(
                FontAwesomeIcons.solidHeart,
                color: Color(kRedColorHeart).withOpacity(0.7),
                size: widget.isTransparent
                    ? widget.size * 1.3
                    : widget.size ?? 15.0,
              ),
            ),
          );
  }
}
