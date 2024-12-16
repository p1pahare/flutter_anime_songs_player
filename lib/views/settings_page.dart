import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/player_current.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);
  static const routeName = '/SettingsPage';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40),
        child: AppBar(
          centerTitle: false,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            Values.settings,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    GetBuilder(
                        init: Get.find<DashboardController>(),
                        initState: (_) {},
                        builder: (c) {
                          return SwitchListTile(
                            value: !(c.darkMode ?? false),
                            onChanged: (dark) {
                              c.changeDarkMode(!dark);
                            },
                            title: Text((c.darkMode ?? false)
                                ? Values.nightMode
                                : Values.dayMode),
                            activeTrackColor:
                                Theme.of(context).primaryColor.withOpacity(0.3),
                            trackOutlineColor: WidgetStatePropertyAll(
                                (c.darkMode ?? false)
                                    ? Theme.of(context).primaryColorDark
                                    : Theme.of(context).primaryColorLight),
                            activeThumbImage:
                                const AssetImage(Values.dayModeAsset),
                            inactiveThumbImage:
                                const AssetImage(Values.nightModeAsset),
                          );
                        }),
                    const DividerB(),
                    ListTile(
                      onTap: () {},
                      title: const Text(Values.language),
                      trailing: const Text("English"),
                    ),
                    const DividerB(),
                    ListTile(
                      onTap: () {},
                      title: const Text(Values.appVersion),
                      trailing: FutureBuilder(
                          initialData: "loading...",
                          future:
                              Get.find<DashboardController>().getVersionInfo(),
                          builder: (context, future) {
                            return Text(future.requireData);
                          }),
                    ),
                    const DividerB(),
                    ListTile(
                      onTap: () {
                        Get.find<DashboardController>()
                            .launchURL(Values.faqsUrl);
                      },
                      title: const Text(Values.faqs),
                    ),
                    const DividerB(),
                    ListTile(
                      onTap: () {
                        Get.find<DashboardController>()
                            .launchURL(Values.tncUrl);
                      },
                      title: const Text(Values.termsConditions),
                    ),
                    const DividerB(),
                    ListTile(
                      onTap: () {
                        Get.find<DashboardController>()
                            .launchURL(Values.privacyUrl);
                      },
                      title: const Text(Values.privacyPolicy),
                    ),
                    const DividerB(),
                  ],
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GetBuilder<DashboardController>(builder: (c) {
              return !c.playerLoaded
                  ? const SizedBox(
                      height: 0,
                    )
                  : SizedBox(
                      height: 100,
                      child: PlayerCurrent(c.underPlayer!,
                          stopPlayer: c.stopPlayer));
            }),
          ),
        ],
      ),
    );
  }
}

class DividerB extends StatelessWidget {
  const DividerB({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      height: 0.4,
    );
  }
}
