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
  }
  final darkTheme = ThemeData(
      fontFamily: 'Pathagonia',
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color.fromARGB(255, 72, 72, 72),
      unselectedWidgetColor: const Color.fromARGB(155, 214, 143, 63),
      primaryColor: const Color.fromARGB(255, 214, 143, 63),
      primaryColorLight: const Color.fromARGB(255, 214, 143, 63),
      primaryColorDark: const Color.fromARGB(255, 226, 172, 236),
      textTheme: const TextTheme(
        bodyText2: TextStyle(
            fontSize: 14.0, fontFamily: 'Pathagonia', color: Colors.white),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.black,
      ),
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
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyText2: TextStyle(
          fontSize: 14.0, fontFamily: 'Pathagonia', color: Colors.black),
    ),
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
