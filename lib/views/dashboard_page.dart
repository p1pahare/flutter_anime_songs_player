import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/explore_page.dart';
import 'package:anime_themes_player/views/playlist_page.dart';
import 'package:anime_themes_player/views/search_page.dart';
import 'package:anime_themes_player/views/settings_page.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:flutter/material.dart';
import 'package:flutter_snake_navigationbar/flutter_snake_navigationbar.dart';
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);
  static const routeName = '/DashboardPage';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Widget getTabFromIndex(int index) {
    switch (index) {
      case 1:
        return const SearchPage();
      case 2:
        return const PlaylistPage();
      default:
        return const ExplorePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
        init: Get.find<DashboardController>(),
        initState: (_) {
          //
          // _init();
        },
        dispose: (_) {},
        builder: (c) {
          return SafeArea(
              top: false,
              right: false,
              left: false,
              child: Scaffold(
                  appBar: AppBar(
                    leading: Container(
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                            color: Colors.white.withAlpha(122)),
                        child: Image.asset(Values.iconA)),
                    title: Text(
                      Values.title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                        icon: Image.asset(
                          Values.settingsAsset,
                          color:
                              Theme.of(context).textTheme.displaySmall?.color ??
                                  Colors.white,
                          height: 26,
                        ),
                        onPressed: () => Get.toNamed(SettingsPage.routeName),
                      ),
                    ],
                  ),
                  body: Stack(
                    children: [
                      getTabFromIndex(c.selectedIndex.value),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GetBuilder<DashboardController>(builder: (c) {
                          return !c.playerLoaded
                              ? const SizedBox(
                                  height: 0,
                                )
                              : Container(
                                  margin: const EdgeInsets.only(bottom: 0),
                                  height: 100,
                                  child: PlayerCurrent(c.underPlayer!,
                                      stopPlayer: c.stopPlayer));
                        }),
                      ),
                    ],
                  ),
                  bottomNavigationBar: SnakeNavigationBar.color(
                    currentIndex: c.selectedIndex.value,
                    snakeShape: SnakeShape.circle,
                    behaviour: SnakeBarBehaviour.pinned,
                    backgroundColor: Theme.of(context)
                        .bottomNavigationBarTheme
                        .backgroundColor,
                    showSelectedLabels: true,
                    unselectedItemColor: Get.theme.primaryColor,
                    showUnselectedLabels: true,
                    onTap: c.updateIndex,
                    items: const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined),
                        label: Values.explore,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.search_outlined,
                        ),
                        label: Values.search,
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.queue_music_outlined,
                        ),
                        label: Values.playlist,
                      )
                    ],
                  ))
              //   FancyBottomNavigation(
              //     initialSelection: c.selectedIndex.value,
              //     circleColor: Get.theme.primaryColor,
              //     activeIconColor: Get.theme.textTheme.bodyMedium!.color,
              //     barBackgroundColor:
              //         Theme.of(context).bottomNavigationBarTheme.backgroundColor,
              //     tabs: [

              //     ],
              //     onTabChangedListener: c.updateIndex,
              //   ),
              // ),
              );
        });
  }
}
