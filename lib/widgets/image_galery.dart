/// This class is customize from - https://github.com/fluttercandies/extended_image

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter/rendering.dart';

class ImageGalery extends StatelessWidget {
  final List images;
  final int index;

  ImageGalery({this.images, this.index});

  @override
  Widget build(BuildContext context) {
    return PicSwiper(
      index,
      images.map((image) => PicSwiperItem(image, des: '')).toList(),
    );
  }
}

class PicSwiperItem {
  String picUrl;
  String des;

  PicSwiperItem(this.picUrl, {this.des = ""});
}

class PicSwiper extends StatefulWidget {
  final int index;
  final List<PicSwiperItem> pics;

  PicSwiper(this.index, this.pics);

  @override
  _PicSwiperState createState() => _PicSwiperState();
}

class _PicSwiperState extends State<PicSwiper> with SingleTickerProviderStateMixin {
  var rebuildIndex = StreamController<int>.broadcast();
  var rebuildSwiper = StreamController<bool>.broadcast();
  AnimationController _animationController;
  Animation<double> _animation;
  Function animationListener;

  List<double> doubleTapScales = <double>[1.0, 2.0];

  int currentIndex;
  bool _showSwiper = true;

  @override
  void initState() {
    currentIndex = widget.index;
    _animationController =
        AnimationController(duration: const Duration(milliseconds: 150), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    rebuildIndex.close();
    rebuildSwiper.close();
    _animationController?.dispose();
    clearGestureDetailsCache();
    //cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    Widget result = Material(
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ExtendedImageGesturePageView.builder(
              itemBuilder: (BuildContext context, int index) {
                var item = widget.pics[index].picUrl;
                Widget image = ExtendedImage.network(
                  item,
                  fit: BoxFit.contain,
                  enableSlideOutPage: true,
                  mode: ExtendedImageMode.gesture,
                  initGestureConfigHandler: (state) {
                    double initialScale = 1.0;

                    if (state.extendedImageInfo != null && state.extendedImageInfo.image != null) {
                      initialScale = _initalScale(
                          size: size,
                          initialScale: initialScale,
                          imageSize: Size(state.extendedImageInfo.image.width.toDouble(),
                              state.extendedImageInfo.image.height.toDouble()));
                    }
                    return GestureConfig(
                        inPageView: true,
                        initialScale: initialScale,
                        maxScale: max(initialScale, 5.0),
                        animationMaxScale: max(initialScale, 5.0),
                        //you can cache gesture state even though page view page change.
                        //remember call clearGestureDetailsCache() method at the right time.(for example,this page dispose)
                        cacheGesture: false);
                  },
                  onDoubleTap: (ExtendedImageGestureState state) {
                    var pointerDownPosition = state.pointerDownPosition;
                    double begin = state.gestureDetails.totalScale;
                    double end;

                    //remove old
                    _animation?.removeListener(animationListener);

                    //stop pre
                    _animationController.stop();

                    //reset to use
                    _animationController.reset();

                    if (begin == doubleTapScales[0]) {
                      end = doubleTapScales[1];
                    } else {
                      end = doubleTapScales[0];
                    }

                    animationListener = () {
                      //print(_animation.value);
                      state.handleDoubleTap(
                          scale: _animation.value, doubleTapPosition: pointerDownPosition);
                    };
                    _animation = _animationController.drive(Tween<double>(begin: begin, end: end));

                    _animation.addListener(animationListener);

                    _animationController.forward();
                  },
                );

                if (index == currentIndex) {
                  return Hero(
                    tag: item + index.toString(),
                    child: image,
                  );
                } else {
                  return image;
                }
              },
              itemCount: widget.pics.length,
              onPageChanged: (int index) {
                currentIndex = index;
                rebuildIndex.add(index);
              },
              controller: PageController(
                initialPage: currentIndex,
              ),
              scrollDirection: Axis.horizontal,
              physics: BouncingScrollPhysics(),
              //physics: ClampingScrollPhysics(),
            ),
            StreamBuilder<bool>(
              builder: (c, d) {
                if (d.data == null || !d.data) return Container();

                return Positioned(
                  bottom: 0.0,
                  left: 0.0,
                  right: 0.0,
                  child: MySwiperPlugin(widget.pics, currentIndex, rebuildIndex),
                );
              },
              initialData: true,
              stream: rebuildSwiper.stream,
            ),
            Positioned(
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: (){Navigator.pop(context);}
              ),
              top: 10,
              right: 10,
            )
          ],
        ));

    return ExtendedImageSlidePage(
      child: result,
      slideAxis: SlideAxis.both,
      slideType: SlideType.onlyImage,
      onSlidingPage: (state) {
        var showSwiper = !state.isSliding;
        if (showSwiper != _showSwiper) {
          _showSwiper = showSwiper;
          rebuildSwiper.add(_showSwiper);
        }
      },
    );
  }

  double _initalScale({Size imageSize, Size size, double initialScale}) {
    var n1 = imageSize.height / imageSize.width;
    var n2 = size.height / size.width;
    if (n1 > n2) {
      final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.width / destinationSize.width;
    } else if (n1 / n2 < 1 / 4) {
      final FittedSizes fittedSizes = applyBoxFit(BoxFit.contain, imageSize, size);
      //final Size sourceSize = fittedSizes.source;
      Size destinationSize = fittedSizes.destination;
      return size.height / destinationSize.height;
    }

    return initialScale;
  }
}

class MySwiperPlugin extends StatelessWidget {
  final List<PicSwiperItem> pics;
  final int index;
  final StreamController<int> reBuild;

  MySwiperPlugin(this.pics, this.index, this.reBuild);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      builder: (BuildContext context, data) {
        return DefaultTextStyle(
          style: TextStyle(color: Colors.white),
          child: Container(
            height: 50.0,
            width: double.infinity,
            color: Colors.black87,
            child: Row(
              children: <Widget>[
                Container(
                  width: 10.0,
                ),
                Text(
                  "${data.data + 1}",
                ),
                Text(
                  " / ${pics.length}",
                ),
                Expanded(
                    child: Text(pics[data.data].des ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 16.0, color: Colors.white))),
                Container(
                  width: 10.0,
                ),
              ],
            ),
          ),
        );
      },
      initialData: index,
      stream: reBuild.stream,
    );
  }
}
