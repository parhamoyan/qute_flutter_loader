import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Custom Widget Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Scaffold(
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomWidget(
                color: Color.fromRGBO(60, 136, 246, 1),
                radius: 130,
                reverseRotation: false,
              ),
              CustomWidget(
                color: Color.fromRGBO(60, 136, 246, .8),
                radius: 135,
                reverseRotation: true,
              ),
              CustomWidget(
                color: Color.fromRGBO(60, 136, 246, .4),
                radius: 140,
                reverseRotation: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomWidget extends StatefulWidget {
  const CustomWidget({
    Key? key,
    required this.color,
    required this.radius,
    required this.reverseRotation,
  }) : super(key: key);

  final Color color;
  final double radius;
  final bool reverseRotation;

  @override
  State<CustomWidget> createState() => _CustomWidgetState();
}

class _CustomWidgetState extends State<CustomWidget> with TickerProviderStateMixin {
  late AnimationController rotationController;
  late AnimationController animationController;
  Animation<double>? angle1;
  Animation<double>? angle2;
  Animation<double>? angle3;
  Animation<double>? angle4;
  Animation<double>? radius;

  double get rotationAngle =>
      (rotationController.value * math.pi * 2) * (widget.reverseRotation ? -1 : 1);

  @override
  void initState() {
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    animationController.addListener(() => setState(() {}));

    initAnimations();

    animationController.addStatusListener(animationStatusListener);
    rotationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        rotationController.forward(from: 0.0);
      }
    });

    animationController.forward();
    rotationController.forward();
    super.initState();
  }

  void animationStatusListener(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      initAnimations();
      animationController.forward(from: 0.0);
      setState(() {});
    }
  }

  void initAnimations() {
    angle1 = createAngle(angle1?.value);
    angle2 = createAngle(angle2?.value);
    angle3 = createAngle(angle3?.value);
    angle4 = createAngle(angle4?.value);
    final begin = radius?.value ?? random(widget.radius, widget.radius * 1.2);
    final end = random(widget.radius, widget.radius * 1.2);
    final tween = Tween<double>(begin: begin, end: end);
    radius = tween.animate(animationController);
  }

  Animation<double> createAngle(double? previousEnd) {
    final begin = previousEnd ?? random(-30, 30, 10);
    final end = random(-30, 30, 10);
    final tween = Tween<double>(begin: begin, end: end);
    return tween.animate(animationController);
  }

  double random(double min, double max, [double? minValue]) {
    final random = math.Random();
    final randomDouble = random.nextDouble() * (max - min) + min;
    return minValue != null ? math.min(randomDouble, minValue) : randomDouble;
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotationAngle,
      child: CustomPaint(
        size: Size.fromRadius(radius!.value),
        painter: EllipsePainter(
          angle1: angle1!.value,
          angle2: angle2!.value,
          angle3: angle3!.value,
          angle4: angle4!.value,
          color: widget.color,
        ),
      ),
    );
  }
}

class EllipsePainter extends CustomPainter {
  EllipsePainter({
    required this.angle1,
    required this.angle2,
    required this.angle3,
    required this.angle4,
    required this.color,
  });

  final double angle1;
  final double angle2;
  final double angle3;
  final double angle4;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    List<double> angles = [
      angle1,
      angle2,
      angle3,
      angle4,
    ];
    drawDeformedCircle(canvas, size, angles);
    // angles = [-20, 12, -40, 0];
    // drawDeformedCircle(canvas, size, Color.fromARGB(255, 232, 41, 41), angles);
  }

  void drawDeformedCircle(Canvas canvas, Size size, List<double> angles) {
    final paint = Paint()..style = PaintingStyle.fill;

    PainterPath path = PainterPath();
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    path.addEllipse(rect);

    int i = -1;
    int angleIndex = 0;
    while (i < path.elements.length - 2) {
      PathElement e0 = path.elementAt(i);
      PathElement e1 = path.elementAt(i + 1);
      PathElement e2 = path.elementAt(i + 2);
      Point p0 = Point(e0.x, e0.y);
      Point p1 = Point(e1.x, e1.y);
      Point p2 = Point(e2.x, e2.y);
      double angle = angles.elementAt(angleIndex);
      double angleRadian = angle * math.pi / 180;
      // Point deformedP0 = getDeformedPoint(noise, Point(size.width/2, size.height/2), p0);
      // Point deformedP1 = getDeformedPoint(noise, Point(size.width/2, size.height/2), p1);
      // Point deformedP2 = getDeformedPoint(noise, Point(size.width/2, size.height/2), p2);
      List<Point> rotatedLine = rotateLineSegment(p0, p1, p2, angleRadian);
      Point rotatedP0 = rotatedLine.elementAt(0);
      Point rotatedP2 = rotatedLine.elementAt(1);
      path.updateElementAt(i, PathElement(rotatedP0.x, rotatedP0.y, e0.type));
      // path.updateElementAt(i + 1, PathElement(deformedP1.x, deformedP1.y, e1.type));
      path.updateElementAt(i + 2, PathElement(rotatedP2.x, rotatedP2.y, e2.type));
      i += 3;
      angleIndex += 1;
    }
    PathElement e0 = path.elementAt(0);
    PathElement e12 = path.elementAt(12);
    path.updateElementAt(12, PathElement(e0.x, e0.y, e12.type));

    paint.color = color;

    Path pathData = Path();

    i = 0;
    while (i < path.elements.length) {
      var element = path.elements[i];
      switch (element.type) {
        case PathElementType.moveTo:
          pathData.moveTo(element.x, element.y);
          i += 1;
          break;
        case PathElementType.lineTo:
          pathData.lineTo(element.x, element.y);
          i += 2;
          break;
        case PathElementType.curveTo:
          var controlPoint1 = path.elements[i + 0];
          var controlPoint2 = path.elements[i + 1];
          var endPoint = path.elements[i + 2];
          pathData.cubicTo(
            controlPoint1.x,
            controlPoint1.y,
            controlPoint2.x,
            controlPoint2.y,
            endPoint.x,
            endPoint.y,
          );
          i += 3;
          break;
        case PathElementType.curveToData:
          break;
      }
    }

    canvas.drawPath(pathData, paint);

    // i = 0;
    // while (i < path.elements.length) {
    //   paint.color = Colors.black;
    //   PathElement e0 = path.elementAt(i);
    //   canvas.drawOval(Rect.fromLTWH(e0.x - 2, e0.y - 2, 4, 4), paint);
    //   i += 1;
    // }
  }

  Point getDeformedPoint(double noise, Point center, Point p) {
    double dx = p.x - center.x;
    double dy = p.y - center.y;
    double angle = math.atan2(dy, dx) * 180 / math.pi;
    double radianAngle = angle * math.pi / 180;
    double x = math.cos(radianAngle);
    double y = math.sin(radianAngle);
    double c = math.sqrt(dx * dx + dy * dy) * (1 + noise);
    double newX = x * c;
    double newY = y * c;
    return Point(center.x + newX, center.y + newY);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PainterPath {
  List<PathElement> elements = [];

  PathElement elementAt(int i) {
    PathElement element;
    int index;
    if (i >= 0) {
      index = i;
    } else {
      index = elements.length + i - 1;
    }
    element = elements.elementAt(index);
    return element;
  }

  void updateElementAt(int i, PathElement updatedElement) {
    int index;
    if (i >= 0) {
      index = i;
    } else {
      index = elements.length + i - 1;
    }
    elements[index] = updatedElement;
  }

  void addEllipse(Rect r) {
    double rx = r.width * 0.5;
    double ry = r.height * 0.5;
    double cx = r.left + rx;
    double cy = r.top + ry;

    // Define kappa as needed
    double kappa = 0.5522847498;

    // Top right
    elements.add(PathElement(cx + rx, cy, PathElementType.moveTo));

    elements.add(PathElement(cx + rx, cy - ry * kappa, PathElementType.curveTo));
    elements.add(PathElement(cx + rx * kappa, cy - ry, PathElementType.curveToData));
    elements.add(PathElement(cx, cy - ry, PathElementType.curveToData));

    // Top left
    elements.add(PathElement(cx - rx * kappa, cy - ry, PathElementType.curveTo));
    elements.add(PathElement(cx - rx, cy - ry * kappa, PathElementType.curveToData));
    elements.add(PathElement(cx - rx, cy, PathElementType.curveToData));

    // Bottom left
    elements.add(PathElement(cx - rx, cy + ry * kappa, PathElementType.curveTo));
    elements.add(PathElement(cx - rx * kappa, cy + ry, PathElementType.curveToData));
    elements.add(PathElement(cx, cy + ry, PathElementType.curveToData));

    // Bottom right
    elements.add(PathElement(cx + rx * kappa, cy + ry, PathElementType.curveTo));
    elements.add(PathElement(cx + rx, cy + ry * kappa, PathElementType.curveToData));
    elements.add(PathElement(cx + rx, cy, PathElementType.curveToData));
  }
}

enum PathElementType { moveTo, lineTo, curveTo, curveToData }

class PathElement {
  double x, y;
  PathElementType type;

  PathElement(this.x, this.y, this.type);
}

class Point {
  double x;
  double y;

  Point(this.x, this.y);

  double distanceTo(Point other) {
    double dx = x - other.x;
    double dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

List<Point> rotateLineSegment(Point p0, Point p1, Point p2, double angle) {
  // Translate points so that p1 is at the origin
  Point p0Translated = Point(p0.x - p1.x, p0.y - p1.y);
  Point p2Translated = Point(p2.x - p1.x, p2.y - p1.y);

  // Calculate rotation
  double sinTheta = math.sin(angle);
  double cosTheta = math.cos(angle);

  // Apply rotation
  double x0New = p0Translated.x * cosTheta - p0Translated.y * sinTheta;
  double y0New = p0Translated.x * sinTheta + p0Translated.y * cosTheta;
  double x2New = p2Translated.x * cosTheta - p2Translated.y * sinTheta;
  double y2New = p2Translated.x * sinTheta + p2Translated.y * cosTheta;

  // Translate back to the original position relative to p1
  Point p0Rotated = Point(x0New + p1.x, y0New + p1.y);
  Point p2Rotated = Point(x2New + p1.x, y2New + p1.y);

  return [p0Rotated, p2Rotated];
}
