import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/playlists_controller.dart';
import 'package:anime_themes_player/controllers/users_controller.dart';
import 'package:anime_themes_player/utilities/functions.dart';
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
                        if (c.currentImage.value.isNotEmpty) {
                          showProfileSheet(context, c);
                        }
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
                        if (c.currentImage.value.isNotEmpty) {
                          showProfileSheet(context, c);
                        }
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
                          onPressed: () =>
                              _showPlaylistInputDialog(context, 'Search'),
                        ),
                      if (isLoggedIn)
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () =>
                              _showPlaylistInputDialog(context, 'Add'),
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
                    onTap: (index) {
                      if (isLoggedIn && index == 2) {
                        Get.find<UsersController>().setMode(LoginMode.loggedIn);
                      }
                      c.updateIndex(index);
                    },
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
              onTap: () => _openUserFormFromProfile(
                c,
                LoginMode.updateUserDetails,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('Change Password'),
              onTap: () => _openUserFormFromProfile(
                c,
                LoginMode.changePassword,
              ),
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
                    onTap: () => _showLogoutConfirmation(context),
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

void _openUserFormFromProfile(
  DashboardController dashboardController,
  LoginMode mode,
) {
  final usersController = Get.find<UsersController>();
  Get.back();
  if (mode == LoginMode.updateUserDetails) {
    usersController.usernameTec.text = dashboardController.me?.user.name ?? '';
    usersController.emailTec.text = dashboardController.me?.user.email ?? '';
  } else if (mode == LoginMode.changePassword) {
    usersController.oldPasswordTec.clear();
    usersController.passwordTec.clear();
    usersController.confirmPassTec.clear();
  }
  usersController.setMode(mode);
  dashboardController.updateIndex(2);
}

void _showLogoutConfirmation(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text(Values.logout),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await Get.find<UsersController>().doLogout();
              Get.back();
            },
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

void _showPlaylistInputDialog(BuildContext context, String action) {
  showDialog(
    context: context,
    builder: (_) => _PlaylistInputDialog(action: action),
  );
}

class _PlaylistInputDialog extends StatefulWidget {
  const _PlaylistInputDialog({required this.action});

  final String action;

  @override
  State<_PlaylistInputDialog> createState() => _PlaylistInputDialogState();
}

class _PlaylistInputDialogState extends State<_PlaylistInputDialog> {
  final TextEditingController _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${widget.action} Playlist'),
      content: TextField(
        controller: _textController,
        autofocus: true,
        decoration: InputDecoration(
          hintText:
              widget.action == 'Add' ? 'Playlist name' : 'Search playlists',
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey,
          ),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Back'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.action == 'Add'
                ? Theme.of(context).colorScheme.secondary
                : Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          onPressed: () async {
            final input = _textController.text.trim();
            if (widget.action == 'Search') {
              Navigator.of(context).pop();
              return;
            }
            if (input.isEmpty) {
              showMessage('Please enter playlist name.');
              return;
            }
            if (!validPlaylist.hasMatch(input)) {
              showMessage(
                  'Playlist name can contain letters, numbers and spaces only.');
              return;
            }
            Navigator.of(context).pop();
            await Get.find<PlaylistsController>().createPlaylist(name: input);
          },
          child: Text(widget.action),
        ),
      ],
    );
  }
}
