import 'package:flutter/material.dart';
import 'dart:ui';

class AppTheme{

  static const primaryColor = Color(0xffa569bd) ;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: false,
    brightness: Brightness.light,

    //COLORS
    colorScheme: const ColorScheme.light(
      primary : Color(0xffa569bd) ,
      secondary: Color(0xff8e44ad) ,
      surface: Colors.white ,
      onSurface: Colors.black87 ,
      tertiary: Color(0xffd7dbdd) ,
      onPrimary: Colors.black ,

    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true ,
      fillColor: primaryColor.withAlpha(50),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide.none ,
      ),
      enabledBorder:  OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide.none,
      ),
      focusedBorder:  OutlineInputBorder(
        borderRadius: BorderRadius.circular(32),
        borderSide: BorderSide(color: Colors.deepPurple.shade700),
      ),
      hintStyle: TextStyle(
        color: Colors.grey.shade300 ,
        wordSpacing: 2,
      ),
      hintFadeDuration: Duration(seconds: 1),

    ),


    //APP BAR THEMEDATA
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white ,
      elevation: 0 ,
      centerTitle: false ,
      titleTextStyle: TextStyle(
        color: Colors.black87 ,
        fontSize: 18 ,
        fontWeight: FontWeight.w700 ,

      ),
      iconTheme: IconThemeData(color: Colors.black),

    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        fontWeight: FontWeight.w700 ,
        fontSize: 32,
        color: Colors.black ,
      ) ,
      titleMedium: TextStyle(
        fontSize: 16 ,
        fontWeight: FontWeight.w500 ,
        color: Colors.black ,
      ) ,
      titleSmall: TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 12 ,
        color: Colors.white ,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xffB048B5),
        foregroundColor: Colors.black87,
        elevation: 2,
        padding: EdgeInsets.symmetric(
            vertical: 8,
             horizontal: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(32) ,
        ) ,
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600 ,
        ),
      ),
    ),
    // Message Bubbles
    cardTheme: CardThemeData(
      shadowColor: Color(0x40FF00FF),
      color: Color(0xffA74AC7),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
        side: BorderSide(
          color: Colors.black38,
        ),
      ),
    ),

    //ICONS
    iconTheme: IconThemeData(
      color: Colors.black,
      size: 32,
    ),
  );
}