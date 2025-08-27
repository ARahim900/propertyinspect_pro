import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ResponsiveHelper {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1200;

  // Check device type
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  // Get responsive spacing
  static double getSpacing(BuildContext context,
      {required double small, double? medium, double? large}) {
    if (isDesktop(context) && large != null) {
      return large;
    } else if (isTablet(context) && medium != null) {
      return medium;
    } else {
      return small;
    }
  }

  // Get responsive icon size
  static double getIconSize(BuildContext context,
      {required double small, double? medium, double? large}) {
    if (isDesktop(context) && large != null) {
      return large;
    } else if (isTablet(context) && medium != null) {
      return medium;
    } else {
      return small;
    }
  }

  // Get responsive font size
  static double getFontSize(BuildContext context,
      {required double small, double? medium, double? large}) {
    if (isDesktop(context) && large != null) {
      return large;
    } else if (isTablet(context) && medium != null) {
      return medium;
    } else {
      return small;
    }
  }

  // Get responsive padding
  static EdgeInsets getPadding(BuildContext context,
      {required EdgeInsets small, EdgeInsets? medium, EdgeInsets? large}) {
    if (isDesktop(context) && large != null) {
      return large;
    } else if (isTablet(context) && medium != null) {
      return medium;
    } else {
      return small;
    }
  }

  // Get responsive button height
  static double getButtonHeight(BuildContext context) {
    if (isDesktop(context)) {
      return 6.h;
    } else if (isTablet(context)) {
      return 7.h;
    } else {
      return 8.h;
    }
  }

  // Get responsive grid count
  static int getGridCount(BuildContext context,
      {int mobile = 1, int tablet = 2, int desktop = 3}) {
    if (isDesktop(context)) {
      return desktop;
    } else if (isTablet(context)) {
      return tablet;
    } else {
      return mobile;
    }
  }

  // Get responsive card width
  static double getCardWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 30.w;
    } else if (isTablet(context)) {
      return 40.w;
    } else {
      return 75.w;
    }
  }

  // Get responsive dialog width
  static double getDialogWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 50.w;
    } else if (isTablet(context)) {
      return 70.w;
    } else {
      return 90.w;
    }
  }

  // Get responsive layout direction
  static Axis getLayoutDirection(BuildContext context,
      {Axis mobile = Axis.vertical, Axis desktop = Axis.horizontal}) {
    return isMobile(context) ? mobile : desktop;
  }

  // Get responsive flex values
  static List<int> getFlexValues(BuildContext context,
      {required List<int> mobile, List<int>? desktop}) {
    return isMobile(context) ? mobile : (desktop ?? mobile);
  }

  // Get responsive aspect ratio
  static double getAspectRatio(BuildContext context,
      {required double mobile, double? tablet, double? desktop}) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    } else {
      return mobile;
    }
  }
}
