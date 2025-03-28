import "package:flutter/material.dart";

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Mali',
  textTheme: const TextTheme().apply(bodyColor: const Color.fromARGB(255, 50, 50, 50)),
  iconTheme: const IconThemeData(color: Color.fromARGB(255, 50, 50, 50),),
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
    primary: Color.fromARGB(255, 50, 50, 50),
    secondary: Colors.white,
  )
  
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Mali',
  textTheme: const TextTheme().apply(bodyColor: Colors.white,),
  iconTheme: const IconThemeData(color: Colors.white,),
  colorScheme: const ColorScheme.dark(
    surface: Color.fromARGB(255, 50, 50, 50),
    primary: Colors.white,
    secondary: Color.fromARGB(255, 40, 40, 40),
  )
);