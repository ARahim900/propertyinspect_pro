import 'package:flutter/material.dart';
import '../core/layout_constants.dart';

/// Helper class for responsive design calculations and utilities
class ResponsiveHelper {
  ResponsiveHelper._();

  /// Get screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < LayoutConstants.breakpointSm) return ScreenSize.small;
    if (width < LayoutConstants.breakpointMd) return ScreenSize.medium;
    if (width < LayoutConstants.breakpointLg) return ScreenSize.large;
    return ScreenSize.extraLarge;
  }

  /// Get responsive value based on screen size
  static T getResponsiveValue<T>(
    BuildContext context, {
    required T small,
    T? medium,
    T? large,
    T? extraLarge,
  }) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return small;
      case ScreenSize.medium:
        return medium ?? small;
      case ScreenSize.large:
        return large ?? medium ?? small;
      case ScreenSize.extraLarge:
        return extraLarge ?? large ?? medium ?? small;
    }
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    return EdgeInsets.all(
      getResponsiveValue(
        context,
        small: LayoutConstants.paddingMd,
        medium: LayoutConstants.paddingLg,
        large: LayoutConstants.paddingXl,
      ),
    );
  }

  /// Get responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context,
        small: LayoutConstants.paddingMd,
        medium: LayoutConstants.paddingLg,
        large: LayoutConstants.paddingXl,
      ),
    );
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context) {
    return getResponsiveValue(
      context,
      small: LayoutConstants.spacingMd,
      medium: LayoutConstants.spacingLg,
      large: LayoutConstants.spacingXl,
    );
  }

  /// Get responsive card width for grid layouts
  static double getCardWidth(BuildContext context, {int columns = 2}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsiveValue(
      context,
      small: LayoutConstants.paddingMd,
      medium: LayoutConstants.paddingLg,
      large: LayoutConstants.paddingXl,
    );
    
    final availableWidth = screenWidth - (padding * 2);
    final spacing = LayoutConstants.gridSpacing * (columns - 1);
    return (availableWidth - spacing) / columns;
  }

  /// Get optimal number of columns for grid based on screen size
  static int getOptimalColumns(BuildContext context, {double minCardWidth = 160}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = getResponsiveValue(
      context,
      small: LayoutConstants.paddingMd,
      medium: LayoutConstants.paddingLg,
      large: LayoutConstants.paddingXl,
    );
    
    final availableWidth = screenWidth - (padding * 2);
    final columns = (availableWidth / (minCardWidth + LayoutConstants.gridSpacing)).floor();
    return columns.clamp(1, 4); // Limit between 1 and 4 columns
  }

  /// Check if device is in landscape mode
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is a tablet
  static bool isTablet(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final diagonal = (screenSize.width * screenSize.width + screenSize.height * screenSize.height);
    return diagonal > 1100000; // Roughly 7 inches diagonal
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return baseSize * 0.9;
      case ScreenSize.medium:
        return baseSize;
      case ScreenSize.large:
        return baseSize * 1.1;
      case ScreenSize.extraLarge:
        return baseSize * 1.2;
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return baseSize;
      case ScreenSize.medium:
        return baseSize * 1.1;
      case ScreenSize.large:
        return baseSize * 1.2;
      case ScreenSize.extraLarge:
        return baseSize * 1.3;
    }
  }

  /// Get responsive border radius
  static double getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    final screenSize = getScreenSize(context);
    switch (screenSize) {
      case ScreenSize.small:
        return baseRadius;
      case ScreenSize.medium:
        return baseRadius * 1.1;
      case ScreenSize.large:
        return baseRadius * 1.2;
      case ScreenSize.extraLarge:
        return baseRadius * 1.3;
    }
  }

  /// Calculate optimal card height based on content and screen size
  static double getOptimalCardHeight(BuildContext context, {
    required double contentHeight,
    double minHeight = 120,
    double maxHeight = 300,
  }) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxAllowedHeight = screenHeight * 0.4; // Max 40% of screen height
    
    return contentHeight
        .clamp(minHeight, maxHeight)
        .clamp(minHeight, maxAllowedHeight);
  }

  /// Get responsive margin
  static EdgeInsets getResponsiveMargin(BuildContext context) {
    return EdgeInsets.all(
      getResponsiveValue(
        context,
        small: LayoutConstants.spacingSm,
        medium: LayoutConstants.spacingMd,
        large: LayoutConstants.spacingLg,
      ),
    );
  }

  /// Get responsive card elevation
  static double getResponsiveElevation(BuildContext context) {
    return getResponsiveValue(
      context,
      small: 2.0,
      medium: 3.0,
      large: 4.0,
    );
  }
}

/// Screen size categories
enum ScreenSize {
  small,
  medium,
  large,
  extraLarge,
}

/// Extension methods for easier responsive design
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => ResponsiveHelper.getScreenSize(this);
  bool get isSmallScreen => screenSize == ScreenSize.small;
  bool get isMediumScreen => screenSize == ScreenSize.medium;
  bool get isLargeScreen => screenSize == ScreenSize.large;
  bool get isExtraLargeScreen => screenSize == ScreenSize.extraLarge;
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  
  EdgeInsets get responsivePadding => ResponsiveHelper.getResponsivePadding(this);
  EdgeInsets get responsiveHorizontalPadding => ResponsiveHelper.getResponsiveHorizontalPadding(this);
  double get responsiveSpacing => ResponsiveHelper.getResponsiveSpacing(this);
  EdgeInsets get responsiveMargin => ResponsiveHelper.getResponsiveMargin(this);
  double get responsiveElevation => ResponsiveHelper.getResponsiveElevation(this);
}