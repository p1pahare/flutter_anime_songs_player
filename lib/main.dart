import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/current_playing.dart';
import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:anime_themes_player/views/playlist_detail.dart';
import 'package:anime_themes_player/views/share_playlist.dart';
import 'package:anime_themes_player/views/splash_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_meedu_videoplayer/meedu_player.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  initMeeduPlayer(iosUseMediaKit: true, androidUseMediaKit: true);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(DashboardController());
    Get.put(ExploreController());
    Get.put(SearchController());
    Get.put(PlaylistController());

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
            case SharePlaylist.routeName:
              Map<int, String>? playlist =
                  settings.arguments as Map<int, String>;
              return CupertinoPageRoute(builder: (context) {
                return SharePlaylist(
                  playlist: playlist,
                );
              });
            case PlaylistDetail.routeName:
              int playlistIndex =
                  ((settings.arguments as List<dynamic>?)?[0] ?? 0);
              Map<int, String> playlist =
                  ((settings.arguments as List<dynamic>?)?[1] ?? {});

              return CupertinoPageRoute(builder: (context) {
                return PlaylistDetail(
                  playlist: playlist,
                  playlistIndex: playlistIndex,
                );
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
