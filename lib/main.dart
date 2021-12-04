import 'package:flutter/material.dart';
import 'package:schedule_com/app/app.dart';

void main() {
  runApp(MaterialApp(
    theme: ThemeData(brightness: Brightness.light,),
    darkTheme: ThemeData(brightness: Brightness.dark,),
    themeMode: ThemeMode.dark,
    title: 'Schedule',
    home: const App(),
  ));
}

