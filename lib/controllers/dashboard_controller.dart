import 'dart:developer';

import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  GetStorage box = GetStorage();
  bool? darkMode;

  DashboardController() {
    box = GetStorage();
    darkMode = box.read<bool>('dark_mode') ?? false;
    selectedIndex.value = box.read<int>('selected_index') ?? 0;
    changeDarkMode(darkMode);
    log("initialized");
  }
  final darkTheme = ThemeData(
      fontFamily: Values.fontFamilyName,
      iconTheme: const IconThemeData(color: Colors.white),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 72, 72, 72),
      unselectedWidgetColor: const Color.fromARGB(155, 214, 143, 63),
      primaryColor: const Color.fromARGB(255, 214, 143, 63),
      primaryColorLight: const Color.fromARGB(255, 214, 143, 63),
      primaryColorDark: const Color.fromARGB(255, 226, 172, 236),
      inputDecorationTheme: const InputDecorationTheme(
          labelStyle: TextStyle(
            color: Color.fromARGB(255, 214, 143, 63),
          ),
          iconColor: Color.fromARGB(255, 214, 143, 63),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              style: BorderStyle.solid,
              color: Color.fromARGB(255, 214, 143, 63),
            ),
          )),
      textTheme: const TextTheme(
        bodyText2: TextStyle(
            fontSize: 14.0,
            fontFamily: Values.fontFamilyName,
            color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
      cardColor: const Color.fromARGB(255, 59, 26, 19),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: Values.fontFamilyName,
          )));
  final lightTheme = ThemeData(
    fontFamily: Values.fontFamilyName,
    brightness: Brightness.light,
    unselectedWidgetColor: const Color.fromARGB(155, 214, 143, 63),
    primaryColor: const Color.fromARGB(255, 214, 143, 63),
    primaryColorLight: const Color.fromARGB(255, 214, 143, 63),
    primaryColorDark: const Color.fromARGB(255, 226, 172, 236),
    inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(
          color: Color.fromARGB(255, 214, 143, 63),
        ),
        iconColor: Color.fromARGB(255, 214, 143, 63),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            color: Color.fromARGB(255, 214, 143, 63),
          ),
        )),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyText2: TextStyle(
          fontSize: 14.0,
          fontFamily: Values.fontFamilyName,
          color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    cardColor: const Color.fromARGB(255, 207, 172, 126),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 214, 143, 63),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: Values.fontFamilyName,
        )),
  );

  changeDarkMode(bool? status) async {
    darkMode = status;
    await box.write('dark_mode', status);
    Get.changeTheme(status ?? true ? darkTheme : lightTheme);
    update();
  }

  void updateIndex(int? index) {
    selectedIndex.value = index ?? 0;

    update();
    box.write('selected_index', selectedIndex.value);
  }
}
