import 'package:flutter/material.dart';

class Responsive {
  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 1024;

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 900;
    if (isTablet(context)) return 720;
    return double.infinity;
  }

  static EdgeInsets pagePadding(BuildContext context) {
    final horizontal = isTablet(context) ? 32.0 : 16.0;
    return EdgeInsets.symmetric(horizontal: horizontal, vertical: 16);
  }

  static int gridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }
}
