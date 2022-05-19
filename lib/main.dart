import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:anime_themes_player/views/splash_page.dart';
import 'package:flutter/cupertino.dart';
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
    Get.find<DashboardController>().initialize();
    return GestureDetector(
      onTap: () {
        Get.focusScope?.unfocus();
      },
      child: GetMaterialApp(
        title: Values.title,
        debugShowCheckedModeBanner: false,
        home: const SplashPage(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case DashboardPage.routeName:
              return CupertinoPageRoute(builder: (context) {
                return const DashboardPage();
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
