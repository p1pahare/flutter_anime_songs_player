import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/explore_page.dart';
import 'package:anime_themes_player/views/playlist_page.dart';
import 'package:anime_themes_player/views/search_page.dart';
import 'package:anime_themes_player/views/settings_page.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:fancy_bottom_navigation_2/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
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
                    child: Image.asset('lib/assets/at_comm_icon.png')),
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
                      color: Theme.of(context).textTheme.displaySmall?.color ??
                          Colors.white,
                      height: 26,
                    ),
                    onPressed: () => Get.toNamed(SettingsPage.routeName),
                  ),
                ],
              ),
              body: getTabFromIndex(c.selectedIndex.value),
              bottomNavigationBar: Container(
                alignment: Alignment.bottomCenter,
                height: !c.playerLoaded ? 60 : 180,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    !c.playerLoaded
                        ? const SizedBox(
                            height: 0,
                          )
                        : Container(
                            height: 120,
                            // padding: const EdgeInsets.only(bottom: 26),

                            child: PlayerCurrent(c.underPlayer!,
                                stopPlayer: c.stopPlayer),
                          ),
                    FancyBottomNavigation(
                      initialSelection: c.selectedIndex.value,
                      circleColor: Get.theme.primaryColor,
                      activeIconColor: Get.theme.textTheme.bodyMedium!.color,
                      barBackgroundColor: Theme.of(context)
                          .bottomNavigationBarTheme
                          .backgroundColor,
                      tabs: [
                        TabData(
                          iconData: Icons.dashboard_outlined,
                          title: Values.explore,
                        ),
                        TabData(
                          iconData: Icons.search_outlined,
                          title: Values.search,
                        ),
                        TabData(
                          iconData: Icons.queue_music_outlined,
                          title: Values.playlist,
                        )
                      ],
                      onTabChangedListener: c.updateIndex,
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
