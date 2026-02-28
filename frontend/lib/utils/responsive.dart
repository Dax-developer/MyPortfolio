import 'package:flutter/material.dart';

class Responsive {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Check device type
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobileBreakpoint &&
      MediaQuery.of(context).size.width < desktopBreakpoint;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= desktopBreakpoint;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive padding
  static EdgeInsets pagePadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.symmetric(horizontal: 16, vertical: 20);
    } else if (isTablet(context)) {
      return EdgeInsets.symmetric(horizontal: 32, vertical: 24);
    } else {
      return EdgeInsets.symmetric(horizontal: 64, vertical: 32);
    }
  }

  static EdgeInsets cardPadding(BuildContext context) {
    if (isMobile(context)) {
      return EdgeInsets.all(16);
    } else if (isTablet(context)) {
      return EdgeInsets.all(20);
    } else {
      return EdgeInsets.all(24);
    }
  }

  // Responsive font sizes
  static double headingLarge(BuildContext context) {
    if (isMobile(context)) return 28;
    if (isTablet(context)) return 32;
    return 40;
  }

  static double headingMedium(BuildContext context) {
    if (isMobile(context)) return 22;
    if (isTablet(context)) return 26;
    return 32;
  }

  static double headingSmall(BuildContext context) {
    if (isMobile(context)) return 18;
    if (isTablet(context)) return 20;
    return 24;
  }

  static double bodyLarge(BuildContext context) {
    if (isMobile(context)) return 14;
    if (isTablet(context)) return 15;
    return 16;
  }

  // Responsive spacing
  static double spacingXS(BuildContext context) =>
      isMobile(context) ? 4 : isTablet(context) ? 6 : 8;

  static double spacingS(BuildContext context) =>
      isMobile(context) ? 8 : isTablet(context) ? 12 : 16;

  static double spacingM(BuildContext context) =>
      isMobile(context) ? 12 : isTablet(context) ? 16 : 20;

  static double spacingL(BuildContext context) =>
      isMobile(context) ? 16 : isTablet(context) ? 24 : 32;

  static double spacingXL(BuildContext context) =>
      isMobile(context) ? 20 : isTablet(context) ? 28 : 40;

  // Grid columns
  static int gridColumns(BuildContext context) {
    if (isMobile(context)) return 2;
    if (isTablet(context)) return 3;
    return 4;
  }

  // Max width for content
  static double maxContentWidth(BuildContext context) {
    final width = getWidth(context);
    if (isDesktop(context)) {
      return 1200;
    }
    return width;
  }
}
