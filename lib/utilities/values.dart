import 'package:anime_themes_player/widgets/round_slider_track_shape.dart';

import 'package:flutter/material.dart';

class Values {
  static const baseUrl = "https://api.animethemes.moe";
  static const videoUrl = "https://v.animethemes.moe";
  static const audioUrl = "https://a.animethemes.moe";
  static const title = "Anime Themes";
  static const loginNote =
      "Login now to keep your favorite themes in a playlist and enjoy them any time on any device.";
  static const registerNote = "Create an account here...";
  static const forgotNote =
      "Enter your email address and we will send a link to reset password.";
  static const login = "Log in";
  static const notHavingAnAccount = "Don't have an account?";
  static const alreadyhaveAnAccount = "Already have an account?";
  static const backTo = "Back to";
  static const login1 = "Login";
  static const agree = "Agree";
  static const tAC = "T&Cs";
  static const privacyPolicy = "Privacy Policy";
  static const and = "and";
  static const signMeup = "Sign me up";
  static const register = "Register";
  static const enterEmail = "Enter Email";
  static const enterUsername = "Enter Username";
  static const enterPassword = "Enter password";
  static const reenterPassword = "Re-enter password";
  static const rememberMe = "Remember me";
  static const forgotPassword = "Forgot Password";
  static const nightModeAsset = 'lib/assets/night-mode.png';
  static const dayModeAsset = 'lib/assets/sunny-day.png';
  static const explore = 'Explore';
  static const search = 'Search';
  static const closePlayer = 'Close Player';
  static const hidePlayer = 'Hide Player';
  static const showPlayer = 'Show Player';
  static const switchToVideo = 'Switch to Video';
  static const switchToAudio = 'Switch to Audio';
  static const playlist = 'Playlist';
  static const searchBy = 'Search By';
  static const playAll = 'Play All';
  static const audio = 'audio';
  static const video = 'video';
  static const noResults = 'No resulting data found';
  static const currentlyPlaying = 'Currently Playing';
  static const fontFamilyName = 'ptsans';
  static const featureNotAddedYet = 'Feature not Added Yet';
  static const localPlaylists = "Local Playlists";
  static const noThemesBeingPlayed =
      'Currently Playing nothing. Please Play from Playlists or add themes to Queue';
  static const takeAScreenShot =
      "Please take a screenshot of this QR Code. You can Save or Share this Playlist and import it anytime on any device.";
  static const errorImage =
      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQcNsW42LouEo4S1FC103szBVQyAuRYoZwsgg&usqp=CAU';
  static final darkTheme = ThemeData(
      fontFamily: Values.fontFamilyName,
      iconTheme: const IconThemeData(color: Colors.white),
      brightness: Brightness.dark,
      cardTheme: const CardTheme(color: Color.fromARGB(255, 214, 143, 63)),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
              foregroundColor: WidgetStateProperty.all(Colors.white),
              backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 214, 143, 63)))),
      sliderTheme: SliderThemeData(
          overlayShape: SliderComponentShape.noOverlay,
          trackHeight: 10,
          thumbColor: Colors.white,
          thumbShape: const SliderThumbShape(),
          activeTrackColor: Colors.white),
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
          bodySmall: TextStyle(
              fontSize: 14.0,
              fontFamily: Values.fontFamilyName,
              color: Colors.white),
          labelSmall: TextStyle(color: Colors.white38)),
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
  static final lightTheme = ThemeData(
    fontFamily: Values.fontFamilyName,
    brightness: Brightness.light,
    unselectedWidgetColor: const Color.fromARGB(155, 214, 143, 63),
    primaryColor: const Color.fromARGB(255, 214, 143, 63),
    primaryColorLight: const Color.fromARGB(255, 214, 143, 63),
    primaryColorDark: const Color.fromARGB(255, 226, 172, 236),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            foregroundColor: WidgetStateProperty.all(Colors.black),
            backgroundColor: WidgetStateProperty.all(
                const Color.fromARGB(255, 214, 143, 63)))),
    sliderTheme: SliderThemeData(
        trackHeight: 10,
        thumbShape: const SliderThumbShape(),
        // trackShape: const RoundSliderTrackShape(radius: 2400),
        overlayShape: SliderComponentShape.noOverlay,
        thumbColor: Colors.black,
        activeTrackColor: Colors.black),
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
        bodySmall: TextStyle(
            fontSize: 14.0,
            fontFamily: Values.fontFamilyName,
            color: Colors.black),
        labelSmall: TextStyle(color: Colors.black38)),
    iconTheme: const IconThemeData(color: Colors.black),
    cardColor: const Color.fromARGB(255, 207, 172, 126),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 214, 143, 63),
        titleTextStyle: TextStyle(
          color: Colors.black,
          fontFamily: Values.fontFamilyName,
        )),
  );
}
