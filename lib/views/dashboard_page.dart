import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/explore_page.dart';
import 'package:anime_themes_player/views/playlist_page.dart';
import 'package:anime_themes_player/views/search_page.dart';
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
        init: DashboardController(),
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
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(!c.playerLoaded ? 40 : 100),
                child: AppBar(
                  leading: Container(
                      decoration: BoxDecoration(
                          borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12)),
                          color: Colors.white.withAlpha(122)),
                      child: Image.asset('lib/assets/at_comm_icon.png')),
                  title: const Text(Values.title),
                  centerTitle: true,
                  actions: [
                    Switch(
                        thumbColor:
                            MaterialStateProperty.all(Colors.grey.shade50),
                        activeThumbImage: const AssetImage(
                          Values.nightModeAsset,
                        ),
                        inactiveThumbImage:
                            const AssetImage(Values.dayModeAsset),
                        value: c.darkMode ?? false,
                        onChanged: c.changeDarkMode)
                  ],
                  bottom: PreferredSize(
                    preferredSize: Size.fromHeight(!c.playerLoaded ? 0 : 60),
                    child: !c.playerLoaded
                        ? const SizedBox(
                            height: 0,
                          )
                        : Container(
                            height: 70,
                            color:
                                Theme.of(context).appBarTheme.backgroundColor,
                            child: PlayerCurrent(c.underPlayer!,
                                stopPlayer: c.stopPlayer)),
                  ),
                ),
              ),
              body: getTabFromIndex(c.selectedIndex.value),
              bottomNavigationBar: FancyBottomNavigation(
                  initialSelection: c.selectedIndex.value,
                  circleColor: Get.theme.primaryColor,
                  activeIconColor: Get.theme.textTheme.bodyMedium!.color,
                  barBackgroundColor: Theme.of(context)
                      .bottomNavigationBarTheme
                      .backgroundColor,
                  tabs: [
                    TabData(
                        iconData: Icons.dashboard_outlined,
                        title: Values.explore),
                    TabData(
                        iconData: Icons.search_outlined, title: Values.search),
                    TabData(
                        iconData: Icons.queue_music_outlined,
                        title: Values.playlist)
                  ],
                  onTabChangedListener: c.updateIndex),
            ),
          );
        });
  }
}
