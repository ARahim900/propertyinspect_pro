import 'package:sizer/sizer.dart';

/// Layout constants for consistent spacing and sizing throughout the app
class LayoutConstants {
  // Spacing Constants
  static double get tinySpacing => 0.5.h;
  static double get smallSpacing => 1.h;
  static double get mediumSpacing => 2.h;
  static double get largeSpacing => 3.h;
  static double get extraLargeSpacing => 4.h;

  // Padding Constants
  static double get tinyPadding => 1.w;
  static double get smallPadding => 2.w;
  static double get mediumPadding => 4.w;
  static double get largePadding => 6.w;
  static double get extraLargePadding => 8.w;

  // Border Radius Constants
  static double get smallRadius => 1.w;
  static double get mediumRadius => 2.w;
  static double get largeRadius => 3.w;
  static double get extraLargeRadius => 4.w;
  static double get circularRadius => 50.w;

  // Card Constants
  static double get cardElevation => 2.0;
  static double get cardRadius => 2.w;
  static double get cardPadding => 4.w;
  static double get cardMargin => 2.w;

  // Button Constants
  static double get buttonHeight => 6.h;
  static double get buttonRadius => 2.w;
  static double get buttonPadding => 4.w;
  static double get iconButtonSize => 12.w;

  // Icon Constants
  static double get smallIcon => 4.w;
  static double get mediumIcon => 5.w;
  static double get largeIcon => 6.w;
  static double get extraLargeIcon => 8.w;

  // Text Field Constants
  static double get textFieldHeight => 6.h;
  static double get textFieldRadius => 2.w;
  static double get textFieldPadding => 3.w;

  // App Bar Constants
  static double get appBarHeight => 8.h;
  static double get appBarIconSize => 6.w;
  static double get appBarElevation => 2.0;

  // Bottom Navigation Constants
  static double get bottomNavHeight => 8.h;
  static double get bottomNavIconSize => 6.w;
  static double get bottomNavElevation => 4.0;

  // List Item Constants
  static double get listItemHeight => 8.h;
  static double get listItemPadding => 4.w;
  static double get listItemRadius => 2.w;

  // Modal Constants
  static double get modalRadius => 4.w;
  static double get modalPadding => 6.w;
  static double get modalSpacing => 3.h;

  // Image Constants
  static double get avatarRadius => 6.w;
  static double get thumbnailSize => 15.w;
  static double get imageRadius => 2.w;

  // Container Constants
  static double get containerMinHeight => 20.h;
  static double get containerPadding => 4.w;
  static double get containerMargin => 2.h;

  // Grid Constants
  static double get gridSpacing => 2.w;
  static double get gridPadding => 4.w;
  static int get gridCrossAxisCount => 2;
  static double get gridChildAspectRatio => 0.8;

  // Shadow Constants
  static double get shadowBlurRadius => 8.0;
  static double get shadowSpreadRadius => 0.0;
  static double get shadowOpacity => 0.1;

  // Animation Constants
  static int get animationDurationFast => 150;
  static int get animationDurationMedium => 300;
  static int get animationDurationSlow => 500;

  // Breakpoints for responsive design
  static double get mobileBreakpoint => 480.0;
  static double get tabletBreakpoint => 768.0;
  static double get desktopBreakpoint => 1024.0;

  // Touch targets (minimum 44pt for accessibility)
  static double get minimumTouchTarget => 44.0;
  static double get recommendedTouchTarget => 48.0;

  // Content constraints
  static double get maxContentWidth => 400.0;
  static double get maxCardWidth => 350.0;
  static double get maxFormWidth => 320.0;

  // Helper methods for responsive spacing
  static double responsiveSpacing(double factor) => factor.h;
  static double responsivePadding(double factor) => factor.w;
  static double responsiveIcon(double factor) => factor.w;
  static double responsiveFont(double factor) => factor.sp;

  // Common edge insets
  static EdgeInsets get tinyInsets => EdgeInsets.all(tinyPadding);
  static EdgeInsets get smallInsets => EdgeInsets.all(smallPadding);
  static EdgeInsets get mediumInsets => EdgeInsets.all(mediumPadding);
  static EdgeInsets get largeInsets => EdgeInsets.all(largePadding);

  static EdgeInsets get horizontalSmall =>
      EdgeInsets.symmetric(horizontal: smallPadding);
  static EdgeInsets get horizontalMedium =>
      EdgeInsets.symmetric(horizontal: mediumPadding);
  static EdgeInsets get horizontalLarge =>
      EdgeInsets.symmetric(horizontal: largePadding);

  static EdgeInsets get verticalSmall =>
      EdgeInsets.symmetric(vertical: smallSpacing);
  static EdgeInsets get verticalMedium =>
      EdgeInsets.symmetric(vertical: mediumSpacing);
  static EdgeInsets get verticalLarge =>
      EdgeInsets.symmetric(vertical: largeSpacing);

  // Common border radius
  static BorderRadius get smallBorderRadius =>
      BorderRadius.circular(smallRadius);
  static BorderRadius get mediumBorderRadius =>
      BorderRadius.circular(mediumRadius);
  static BorderRadius get largeBorderRadius =>
      BorderRadius.circular(largeRadius);
  static BorderRadius get circularBorderRadius =>
      BorderRadius.circular(circularRadius);

  // Card decoration
  static BoxDecoration cardDecoration({
    Color? color,
    Color? shadowColor,
    double? elevation,
    BorderRadius? borderRadius,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: borderRadius ?? mediumBorderRadius,
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? Colors.black).withValues(
            alpha: elevation != null ? (elevation * 0.05) : shadowOpacity,
          ),
          blurRadius: elevation != null ? (elevation * 2) : shadowBlurRadius,
          spreadRadius: shadowSpreadRadius,
          offset: Offset(0, elevation != null ? elevation : 2),
        ),
      ],
    );
  }
}
