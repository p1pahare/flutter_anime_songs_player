import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({
    Key? key,
  }) : super(key: key);
  static const routeName = '/DashboardPage';

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int currentState = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(40),
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
              GetBuilder<DashboardController>(
                init: DashboardController(),
                initState: (_) {},
                builder: (c) {
                  return Switch(
                      thumbColor:
                          MaterialStateProperty.all(Colors.grey.shade50),
                      activeThumbImage: const AssetImage(
                        Values.nightModeAsset,
                      ),
                      inactiveThumbImage: const AssetImage(Values.dayModeAsset),
                      value: c.darkMode ?? false,
                      onChanged: c.changeDarkMode);
                },
              )
            ],
          ),
        ),
        bottomNavigationBar: GetBuilder<DashboardController>(
          init: DashboardController(),
          initState: (_) {},
          builder: (c) {
            return FancyBottomNavigation(
                circleColor: Theme.of(context).primaryColor,
                inactiveIconColor:
                    Theme.of(context).appBarTheme.titleTextStyle?.color ??
                        const Color(0xffffffff),
                activeIconColor:
                    Theme.of(context).appBarTheme.titleTextStyle?.color ??
                        const Color(0xffffffff),
                textColor:
                    Theme.of(context).appBarTheme.titleTextStyle?.color ??
                        const Color(0xffffffff),
                barBackgroundColor:
                    Theme.of(context).bottomNavigationBarTheme.backgroundColor,
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
                onTabChangedListener: c.updateIndex);
          },
        ));
  }
}
