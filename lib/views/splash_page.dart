import 'package:anime_themes_player/controllers/search_controller.dart'
    as get_search;
import 'package:anime_themes_player/controllers/explore_controller.dart';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/views/dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    loadData();
    super.initState();
  }

  loadData() async {
    Get.lazyPut(() => DashboardController());
    Get.lazyPut(() => ExploreController());
    Get.putAsync(() async => get_search.SearchController());
    Get.lazyPut(() => PlaylistController());
    await GetStorage.init();
    Get.find<DashboardController>().initialize();
    Get.find<PlaylistController>().initialize();
    await Future.delayed(const Duration(seconds: 2));
    FlutterNativeSplash.remove();
    Get.offAllNamed(DashboardPage.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
