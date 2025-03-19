import "package:flutter/material.dart";

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  fontFamily: 'Mali',
  textTheme: const TextTheme().apply(bodyColor: const Color.fromARGB(255, 50, 50, 50)),
  colorScheme: const ColorScheme.light(
    surface: Colors.white,
  )
  
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  fontFamily: 'Mali',
  textTheme: const TextTheme().apply(bodyColor: Colors.white,),
  colorScheme: const ColorScheme.dark(
    surface: Color.fromARGB(255, 50, 50, 50),
  )
);