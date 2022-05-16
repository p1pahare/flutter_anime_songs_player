import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';

class DashboardController extends GetxController {
  var selectedIndex = 0.obs;
  GetStorage box = GetStorage();
  bool? darkMode;
  AudioPlayer? audioPlayer;
  DashboardController() {
    box = GetStorage();
    darkMode = box.read<bool>('dark_mode') ?? false;
    changeDarkMode(darkMode);
    audioPlayer = AudioPlayer();

    audioPlayer!
        .setAudioSource(ConcatenatingAudioSource(children: [
      AudioSource.uri(Uri.parse(
          "https://themesmoeaudio.sfo2.digitaloceanspaces.com/themes/38691/OP2.mp3")),
      AudioSource.uri(Uri.parse(
          "https://themesmoeaudio.sfo2.digitaloceanspaces.com/themes/6573/OP.mp3")),
      AudioSource.uri(Uri.parse(
          "https://themesmoeaudio.sfo2.digitaloceanspaces.com/themes/37451/OP.mp3")),
    ]))
        .catchError((error) {
      // catch load errors: 404, invalid url ...
      log("An error occured $error");
    });
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

  @override
  void dispose() {
    audioPlayer!.dispose();
    super.dispose();
  }
}
