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
  final darkColorScheme = const ColorScheme.dark(
    primary: Color.fromARGB(255, 68, 137, 70),
    secondary: Color.fromARGB(255, 227, 255, 178),
  );
  final lightColorScheme = const ColorScheme.light(
      primary: Color.fromARGB(255, 68, 137, 70),
      secondary: Color.fromARGB(255, 226, 172, 236));
  final darkTextTheme = const TextTheme(
    bodyText1: TextStyle(),
    bodyText2: TextStyle(),
  );
  final lightTextTheme = const TextTheme(
      bodyText1: TextStyle(fontSize: 16, color: Colors.pink),
      bodyText2: TextStyle(fontSize: 16, color: Colors.pink));
  changeDarkMode(bool? status) async {
    darkMode = status;
    await box.write('dark_mode', status);
    Get.changeTheme(status ?? true
        ? ThemeData.from(
            colorScheme: darkColorScheme,
          )
        : ThemeData.from(colorScheme: lightColorScheme));
    update();
  }

  void updateIndex(int? index) {
    selectedIndex.value = index ?? 0;
    update();
  }
}
