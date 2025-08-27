/// Layout constants for consistent spacing and sizing throughout the application
class LayoutConstants {
  LayoutConstants._();

  // Spacing constants
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Padding constants
  static const double paddingXs = 4.0;
  static const double paddingSm = 8.0;
  static const double paddingMd = 16.0;
  static const double paddingLg = 20.0;
  static const double paddingXl = 24.0;
  static const double paddingXxl = 32.0;

  // Border radius constants
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusRound = 999.0;

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;

  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardElevationHover = 4.0;
  static const double cardMinHeight = 120.0;
  static const double cardMaxWidth = 400.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightLg = 56.0;
  static const double buttonMinWidth = 88.0;

  // Input field dimensions
  static const double inputHeight = 48.0;
  static const double inputHeightSm = 36.0;
  static const double inputHeightLg = 56.0;

  // App bar dimensions
  static const double appBarHeight = 56.0;
  static const double appBarHeightLg = 64.0;

  // Bottom navigation dimensions
  static const double bottomNavHeight = 80.0;
  static const double bottomNavIconSize = 24.0;

  // FAB dimensions
  static const double fabSize = 56.0;
  static const double fabSizeSm = 40.0;
  static const double fabSizeLg = 64.0;

  // List item dimensions
  static const double listItemHeight = 72.0;
  static const double listItemHeightSm = 56.0;
  static const double listItemHeightLg = 88.0;

  // Avatar dimensions
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  // Screen breakpoints
  static const double breakpointSm = 600.0;
  static const double breakpointMd = 960.0;
  static const double breakpointLg = 1280.0;
  static const double breakpointXl = 1920.0;

  // Content max widths
  static const double contentMaxWidthSm = 600.0;
  static const double contentMaxWidthMd = 960.0;
  static const double contentMaxWidthLg = 1200.0;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Opacity values
  static const double opacityDisabled = 0.38;
  static const double opacityMedium = 0.6;
  static const double opacityHigh = 0.87;

  // Shadow values
  static const double shadowBlurRadius = 8.0;
  static const double shadowSpreadRadius = 0.0;
  static const Offset shadowOffset = Offset(0, 2);

  // Grid spacing
  static const double gridSpacing = 16.0;
  static const double gridSpacingSm = 8.0;
  static const double gridSpacingLg = 24.0;

  // Safe area padding
  static const double safeAreaPadding = 16.0;
  static const double safeAreaPaddingBottom = 24.0;

  // Responsive helpers
  static bool isSmallScreen(double width) => width < breakpointSm;
  static bool isMediumScreen(double width) => width >= breakpointSm && width < breakpointMd;
  static bool isLargeScreen(double width) => width >= breakpointMd;

  // Responsive padding
  static double getResponsivePadding(double screenWidth) {
    if (isSmallScreen(screenWidth)) return paddingMd;
    if (isMediumScreen(screenWidth)) return paddingLg;
    return paddingXl;
  }

  // Responsive spacing
  static double getResponsiveSpacing(double screenWidth) {
    if (isSmallScreen(screenWidth)) return spacingMd;
    if (isMediumScreen(screenWidth)) return spacingLg;
    return spacingXl;
  }

  // Card aspect ratios
  static const double cardAspectRatioSquare = 1.0;
  static const double cardAspectRatioWide = 16 / 9;
  static const double cardAspectRatioTall = 3 / 4;
  static const double cardAspectRatioMetric = 0.85; // Optimized for metric cards
}