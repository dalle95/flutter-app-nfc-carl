import 'package:flutter/material.dart';

final theme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blue,
  primaryColorDark: const Color.fromARGB(255, 11, 50, 113),
  secondaryHeaderColor: Colors.orange,
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Color.fromRGBO(255, 152, 0, 1),
    onPrimary: Colors.orangeAccent,
    secondary: Color.fromRGBO(82, 68, 56, 1),
    onSecondary: Colors.black87,
    background: Colors.white,
    onBackground: Colors.black87,
    error: Colors.redAccent,
  ),
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    backgroundColor: Colors.orangeAccent,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.orange,
  ),
  buttonTheme: const ButtonThemeData(
    buttonColor: Colors.orange,
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.orange),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
    ),
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(
        fontSize: 20, color: Colors.orange, fontStyle: FontStyle.normal),
    bodyLarge: TextStyle(
      fontSize: 25.0,
      color: Colors.black,
      fontFamily: 'Hind',
    ),
    bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
  ),
);
