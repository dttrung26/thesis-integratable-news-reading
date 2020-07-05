import 'package:flutter/material.dart';

class CustomScrollPhysic extends ScrollPhysics {
  const CustomScrollPhysic({ScrollPhysics parent, this.width}) : super(parent: parent);
  final double width;

  @override
  CustomScrollPhysic applyTo(ScrollPhysics ancestor) {
    return CustomScrollPhysic(parent: buildParent(ancestor), width: width);
  }

  double _getPage(ScrollPosition position) {
    print(width.toString());
    return position.pixels / width;
  }

  double _getPixels(ScrollPosition position, double page) {
    return page * width;
  }

  double _getTargetPixels(ScrollPosition position, Tolerance tolerance, double velocity) {
    double page = _getPage(position);
    if (velocity < -tolerance.velocity)
      page -= 0.5;
    else if (velocity > tolerance.velocity) page += 0.5;
    return _getPixels(position, page.roundToDouble());
  }

  @override
  Simulation createBallisticSimulation(ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent))
      return super.createBallisticSimulation(position, velocity);
    final Tolerance tolerance = this.tolerance;

    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels)
      return ScrollSpringSimulation(spring, position.pixels, target, 0.2, tolerance: tolerance);
    return null;
  }
}
