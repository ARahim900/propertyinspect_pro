import 'package:flutter/material.dart';

class CurrencyHelper {
  // Omani Rial currency formatting
  static String formatOMR(double value) {
    return '${value.toStringAsFixed(3)} OMR';
  }

  // Omani Rial currency formatting with symbol
  static String formatOMRWithSymbol(double value) {
    return 'ر.ع. ${value.toStringAsFixed(3)}';
  }

  // Parse currency string to double (handles both $ and OMR formats)
  static double parseCurrency(String currencyString) {
    final cleanString = currencyString.replaceAll(RegExp(r'[^\d.]'), '').trim();

    return double.tryParse(cleanString) ?? 0.0;
  }

  // Convert from USD to OMR (exchange rate as of 2025)
  static double convertUSDToOMR(double usdAmount) {
    const double exchangeRate = 0.385; // 1 USD = 0.385 OMR (approximate)
    return usdAmount * exchangeRate;
  }

  // Convert from OMR to USD
  static double convertOMRToUSD(double omrAmount) {
    const double exchangeRate = 2.597; // 1 OMR = 2.597 USD (approximate)
    return omrAmount * exchangeRate;
  }

  // Format currency input field
  static String formatCurrencyInput(String input) {
    // Remove any non-numeric characters except decimal point
    String cleanInput = input.replaceAll(RegExp(r'[^\d.]'), '');

    // Ensure only one decimal point
    final parts = cleanInput.split('.');
    if (parts.length > 2) {
      cleanInput = '${parts[0]}.${parts[1]}';
    }

    // Limit decimal places to 3 for OMR
    if (parts.length == 2 && parts[1].length > 3) {
      cleanInput = '${parts[0]}.${parts[1].substring(0, 3)}';
    }

    return cleanInput;
  }

  // Get currency symbol
  static String getCurrencySymbol() {
    return 'ر.ع.'; // Omani Rial symbol
  }

  // Get currency code
  static String getCurrencyCode() {
    return 'OMR';
  }

  // Format for display in lists and cards
  static String formatForDisplay(double value, {bool showSymbol = true}) {
    if (showSymbol) {
      return formatOMRWithSymbol(value);
    } else {
      return formatOMR(value);
    }
  }

  // Format large numbers with K, M suffixes
  static String formatLargeAmount(double value, {bool showSymbol = true}) {
    final symbol = showSymbol ? getCurrencySymbol() : '';

    if (value >= 1000000) {
      return '$symbol ${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '$symbol ${(value / 1000).toStringAsFixed(1)}K';
    } else {
      return showSymbol ? formatOMRWithSymbol(value) : formatOMR(value);
    }
  }

  // Validate currency input
  static bool isValidCurrencyAmount(String input) {
    final cleanInput = formatCurrencyInput(input);
    final value = double.tryParse(cleanInput);

    return value != null && value >= 0 && value <= 999999.999;
  }

  // Get formatted currency text style
  static TextStyle getCurrencyTextStyle(
    BuildContext context, {
    FontWeight? fontWeight,
    double? fontSize,
    Color? color,
  }) {
    return TextStyle(
      fontWeight: fontWeight ?? FontWeight.w600,
      fontSize: fontSize,
      color: color ?? Theme.of(context).colorScheme.onSurface,
      fontFamily: 'Inter', // Consistent with app font
    );
  }
}
