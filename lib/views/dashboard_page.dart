import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/users_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/views/explore_page.dart';
import 'package:anime_themes_player/views/unregistered_page.dart';
import 'package:anime_themes_player/views/search_page.dart';
import 'package:anime_themes_player/views/settings_page.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
        return const UnregisteredPage();
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
          ImageProvider imageProvider = c.currentImage.value.isEmpty
              ? const AssetImage(Values.iconA) as ImageProvider
              : CachedNetworkImageProvider(c.currentImage.value);
          final isLoggedIn = c.currentTitle.value.isNotEmpty;
          final isPlaylistPage = c.selectedIndex.value == 2;
          return SafeArea(
              top: false,
              right: false,
              left: false,
              child: Scaffold(
                  appBar: AppBar(
                    leading: GestureDetector(
                      onTap: () {
                        if (c.currentImage.value.isNotEmpty)
                          {showProfileSheet(context, c);}
                      },
                      child: Container(
                          clipBehavior: Clip.hardEdge,
                          margin: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (c.currentImage.value.isEmpty)
                                  ? Colors.white.withAlpha(122)
                                  : Colors.transparent),
                          child: Image(image: imageProvider)),
                    ),
                    title: GestureDetector(
                      onTap: () {
                        if (c.currentImage.value.isNotEmpty)
                          {showProfileSheet(context, c);}
                      },
                      child: Text(
                        isLoggedIn ? c.currentTitle.value : Values.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    actions: [
                      if (!isLoggedIn)
                        IconButton(
                          icon: Image.asset(
                            Values.settingsAsset,
                            color: Colors.white,
                            height: 26,
                          ),
                          onPressed: () => Get.toNamed(SettingsPage.routeName),
                        ),
                      if (isLoggedIn && isPlaylistPage)
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      if (isLoggedIn)
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () {},
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
                  )));
        });
  }
}

void showProfileSheet(BuildContext context, DashboardController c) {
  ImageProvider imageProvider = c.currentImage.value.isEmpty
      ? const AssetImage(Values.iconA) as ImageProvider
      : CachedNetworkImageProvider(c.currentImage.value);
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
              ),
              currentAccountPicture: Container(
                  clipBehavior: Clip.hardEdge,
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (c.currentImage.value.isEmpty)
                          ? Colors.white.withAlpha(122)
                          : Colors.transparent),
                  child: Image(image: imageProvider)),
              accountName: Text(c.currentTitle.value,
                  style: Theme.of(context).textTheme.headlineSmall),
              accountEmail: Text(c.me?.user.email ?? "",
                  style: Theme.of(context).textTheme.bodyMedium),
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit Profile'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: Image.asset(
                Values.settingsAsset,
                color: Theme.of(context).textTheme.displaySmall?.color ??
                    Colors.white,
                height: 26,
              ),
              title: const Text('Settings'),
              onTap: () => Get.offAndToNamed(SettingsPage.routeName),
            ),
            const Divider(),
            GetBuilder(
                init: Get.find<UsersController>(),
                initState: (_) {},
                builder: (c) {
                  if (c.wait.value) {
                    return const ProgressIndicatorButton(
                      radius: 20,
                    );
                  }
                  return ListTile(
                    onTap: () {
                      Get.find<UsersController>()
                          .doLogout()
                          .then((_) => Get.back());
                    },
                    leading: const Icon(Icons.logout),
                    title: const Text(Values.logout),
                  );
                }),
          ],
        ),
      ),
    ),
  );
}
