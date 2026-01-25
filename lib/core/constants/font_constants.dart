import 'package:flutter/material.dart';

class AppFonts {
  AppFonts._();

  /// Kiran font family for Devanagari/Marathi text
  /// This font displays romanized text as Devanagari script
  static const String kiran = 'Kiran';

  /// Text style for menu item names using Kiran font
  static TextStyle kiranText({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: kiran,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      decoration: decoration,
    );
  }

  /// Text style for category names using Kiran font
  static TextStyle kiranCategory({
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: kiran,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
