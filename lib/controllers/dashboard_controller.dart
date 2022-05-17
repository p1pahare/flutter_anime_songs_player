import 'dart:developer';

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
    changeDarkMode(darkMode);
    log("initialized");
  }
  final darkTheme = ThemeData(
      fontFamily: 'Pathagonia',
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
            fontSize: 14.0, fontFamily: 'Pathagonia', color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
      cardColor: const Color.fromARGB(28, 24, 24, 24),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Pathagonia',
          )));
  final lightTheme = ThemeData(
    fontFamily: 'Pathagonia',
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
          fontSize: 14.0, fontFamily: 'Pathagonia', color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    cardColor: const Color.fromARGB(199, 207, 172, 126),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 214, 143, 63),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: 'Pathagonia',
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
  }
}
