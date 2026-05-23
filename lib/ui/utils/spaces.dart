import 'package:flutter/material.dart';

class FillView extends StatelessWidget {
  const FillView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(child: SizedBox());
  }
}

enum SpacingSize { xxs, xs, s, m, l, xl, xxl, xxxl }

Widget addHeight(SpacingSize size) {
  var spacing = 0.0;
  switch (size) {
    case SpacingSize.xxs:
      spacing = 5;
      break;
    case SpacingSize.xs:
      spacing = 10;
      break;
    case SpacingSize.s:
      spacing = 20;
      break;
    case SpacingSize.m:
      spacing = 30;
      break;
    case SpacingSize.l:
      spacing = 40;
      break;
    case SpacingSize.xl:
      spacing = 50;
      break;
    case SpacingSize.xxl:
      spacing = 60;
      break;
    case SpacingSize.xxxl:
      spacing = 70;
      break;
  }
  return SizedBox(height: spacing);
}

Widget addWidth(SpacingSize size) {
  var spacing = 0.0;
  switch (size) {
    case SpacingSize.xxs:
      spacing = 5;
      break;
    case SpacingSize.xs:
      spacing = 10;
      break;
    case SpacingSize.s:
      spacing = 20;
      break;
    case SpacingSize.m:
      spacing = 30;
      break;
    case SpacingSize.l:
      spacing = 40;
      break;
    case SpacingSize.xl:
      spacing = 50;
      break;
    case SpacingSize.xxl:
      spacing = 60;
      break;
    case SpacingSize.xxxl:
      spacing = 70;
      break;
  }
  return SizedBox(width: spacing);
}

// for border raduis
BorderRadius appRadius(SpacingSize size) {
  double radius = 0.0;
  switch (size) {
    case SpacingSize.xxs:
      radius = 4;
      break;
    case SpacingSize.xs:
      radius = 6;
      break;
    case SpacingSize.s:
      radius = 8;
      break;
    case SpacingSize.m:
      radius = 12;
      break;
    case SpacingSize.l:
      radius = 16;
      break;
    case SpacingSize.xl:
      radius = 20;
      break;
    case SpacingSize.xxl:
      radius = 24;
      break;
    case SpacingSize.xxxl:
      radius = 32;
      break;
  }
  return BorderRadius.circular(radius);
}
