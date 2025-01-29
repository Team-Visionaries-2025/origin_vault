import 'package:flutter/material.dart';
import 'package:origin_vault/core/theme/app_pallete.dart';

class Apptheme {
  static final _border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(21),
    borderSide: const BorderSide(
      color: Colors.transparent,
    ),
  );
  static final themeMode = ThemeData.dark().copyWith(
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(69 - 45),
      filled: true,
      fillColor: AppPallete.fieldcolor,
      prefixIconColor: AppPallete.iconColor,
      hintStyle: const TextStyle(
        fontWeight: FontWeight.w300,
      ),
      iconColor: AppPallete.backgroundColor,
      enabledBorder: Apptheme._border,
      focusedBorder: _border,
    ),
  );
}
