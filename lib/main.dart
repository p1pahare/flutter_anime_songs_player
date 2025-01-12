import 'package:anime_themes_player/models/theme_album.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/album_detail_page.dart';
import 'package:anime_themes_player/views/current_playing.dart';
import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:anime_themes_player/views/playlist_detail.dart';
import 'package:anime_themes_player/views/settings_page.dart';
import 'package:anime_themes_player/views/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: GetMaterialApp(
        title: Values.title,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
        theme: Values.lightTheme,
        darkTheme: Values.darkTheme,
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case DashboardPage.routeName:
              return CupertinoPageRoute(builder: (context) {
                return const DashboardPage();
              });
            case CurrentPlaying.routeName:
              return CupertinoPageRoute(builder: (context) {
                return const CurrentPlaying();
              });
            case PlaylistDetail.routeName:
              return CupertinoPageRoute(builder: (context) {
                return const PlaylistDetail();
              });
            case SettingsPage.routeName:
              return CupertinoPageRoute(builder: (context) {
                return const SettingsPage();
              });
            case AlbumDetailPage.routeName:
              return CupertinoPageRoute(builder: (context) {
                if (settings.arguments is ThemeAlbum) {
                  return AlbumDetailPage(
                    themeAlbum: settings.arguments as ThemeAlbum,
                  );
                }
                return const SizedBox.expand();
              });
            case '/':
            default:
              return CupertinoPageRoute(builder: (context) {
                return const SplashPage();
              });
          }
        },
      ),
    );
  }
}
