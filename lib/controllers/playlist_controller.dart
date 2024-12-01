import 'dart:async';
import 'dart:developer';
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/repositories/anime_theme_repo.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum LoginMode {
  loading,
  loggedIn,
  login,
  register,
  forgotPassword,
  changePassword,
  updateUserDetails
}

class PlaylistController extends GetxController {
  AnimeThemeRepository networkCalls = AnimeThemeRepository();
  RxList<Map<int, String>> playlists = RxList.empty();
  GetStorage box = GetStorage();
  RxList<AudioEntry> listings = RxList.empty();
  RxStatus status = RxStatus.empty();
  Rxn<LoginMode> mode = Rxn(LoginMode.login);
  final usernameTec = TextEditingController();
  final emailTec = TextEditingController();
  final passwordTec = TextEditingController();
  final confirmPassTec = TextEditingController();
  RxBool agree = false.obs;
  RxBool rememberMe = false.obs;

  void setRememberMe(bool? rememberMe) {
    this.rememberMe.value = rememberMe ?? true;
    update();
  }

  void setAgree(bool? agree) {
    this.agree.value = agree ?? true;
    update();
  }

  bool showEmail() =>
      mode.value == LoginMode.login ||
      mode.value == LoginMode.register ||
      mode.value == LoginMode.forgotPassword;

  bool showPassoword() =>
      mode.value == LoginMode.login || mode.value == LoginMode.register;

  bool showCPassoword() => mode.value == LoginMode.register;

  bool showAgree() => mode.value == LoginMode.register;

  bool showUsername() => mode.value == LoginMode.register;

  bool showRemember() => mode.value == LoginMode.login;

  Future setMode(LoginMode loginMode) async {
    mode.value = loginMode;
    await Future.delayed(const Duration(milliseconds: 500));
    update();
  }

  String getTitle() {
    if (mode.value == LoginMode.login) {
      return Values.loginNote;
    }
    if (mode.value == LoginMode.forgotPassword) {
      return Values.forgotNote;
    }
    if (mode.value == LoginMode.register) {
      return Values.registerNote;
    }
    return "";
  }

  String getLinkTitle() {
    if (mode.value == LoginMode.login) {
      return Values.notHavingAnAccount;
    }
    if (mode.value == LoginMode.forgotPassword) {
      return Values.backTo;
    }
    if (mode.value == LoginMode.register) {
      return Values.alreadyhaveAnAccount;
    }
    return "";
  }

  MapEntry<String, LoginMode> getLink() {
    if (mode.value == LoginMode.login) {
      return const MapEntry(Values.register, LoginMode.register);
    }
    if (mode.value == LoginMode.forgotPassword) {
      return const MapEntry(Values.login1, LoginMode.login);
    }
    if (mode.value == LoginMode.register) {
      return const MapEntry(Values.login1, LoginMode.login);
    }
    return const MapEntry(Values.register, LoginMode.register);
  }

  final TextEditingController playlistName = TextEditingController();
  initialize() {
    box = GetStorage();
    playlists.add({0: "SONGGGG"});
    playlists.refresh();
    log("initialized");
    update();
  }

  String songCount(Map<int, String> playlist) =>
      "${(playlist.values.where((element) => element != "0000000").length - 2)} Songs";

  bool containsPlaylistId(String playlistId) {
    bool exists = false;
    for (final element in playlists) {
      if (element[0] == playlistId) exists = true;
    }
    return exists;
  }

  void onClear() {
    if (playlistName.text.isNotEmpty) {
      playlistName.clear();
    }
    update();
  }

  void onCreatePlaylist() {
    Get.focusScope?.unfocus();

    if (playlistName.text.isNotEmpty) {
      playlistName.clear();
    }
    update();
  }

  addToPlayList(String playlistId, String themeId,
      Map<String, dynamic> songmetadata) async {
    int playlistIndex =
        playlists.indexWhere((element) => element[0] == playlistId);
    int emptyIndex = playlists[playlistIndex]
        .entries
        .firstWhere(
          (element) => element.value == '0000000',
        )
        .key;
    String paddedThemeId = themeId.padLeft(7, '0');
    int existingId = playlists[playlistIndex]
        .entries
        .toList()
        .indexWhere((element) => element.value == paddedThemeId);

    if (existingId != -1) {
      showMessage("This theme already present in the playlist.");
      return;
    }
    playlists[playlistIndex][emptyIndex] = paddedThemeId;
    for (MapEntry me in playlists[playlistIndex].entries) {
      if (me.value != '0000000') log("${me.key}  _______:______ ${me.value}");
    }
    playlists.refresh();
    await writePlayliststoBox();
    await writeSongMetaDataToBox(paddedThemeId, songmetadata);
    showMessage("Song added to the playlist 'Playlist name' Successfully.");
  }

  Future editPlaylistsAndSave(
      int playlistIndex, String playListId, String playlistName) async {
    List<String> stringList =
        listings.map((e) => e.id.padLeft(7, '0')).toList();
    stringList.insert(0, playListId);
    stringList.insert(1, playlistName);
    stringList.insertAll(stringList.length,
        List.generate(1002 - stringList.length, (index) => '0000000'));
    playlists[playlistIndex].clear();
    playlists[playlistIndex].addAll(Map.fromIterables(
        List.generate(stringList.length, (index) => index), stringList));
    await writePlayliststoBox();
  }

  Future deleteFromPlayList(
      String playlistId, String themeId, BuildContext context) async {
    update(['detail']);
    showMessage("Song removed from the playlist 'playlist name Successfully.");
  }

  bool playlistIsFull(String playlistId) => playlists
      .where((p0) => p0[0] == playlistId)
      .first
      .values
      .where((element) => element == "0000000")
      .isEmpty;

  deletePlayList(Map<int, String> playList) async {
    bool? delete = await Get.defaultDialog<bool>(
        buttonColor: Get.theme.unselectedWidgetColor,
        cancelTextColor: Get.theme.primaryColor,
        confirmTextColor: Get.theme.textTheme.bodySmall!.color,
        content: const Text(
            "Do you really want to delete playlist 'Playlist Name' with 333 Themes ?"),
        onConfirm: () => Get.back(result: true),
        textConfirm: 'Confirm',
        onCancel: () => Get.back(result: false));
    if (delete == null || !delete) return;
    playlists.removeWhere((element) => element[0] == playList[0]);

    playlists.refresh();

    await writePlayliststoBox();
  }

  Future writePlayliststoBox() async {
    await box.write(
        'playlists', playlists.map<String>((element) => "").toList());
    update();
  }

  Future<void> writeSongMetaDataToBox(
      String themeId, Map<String, dynamic> songmetadata) async {
    await box.write('theme_$themeId', songmetadata);
    update(['detail']);
  }

  metadataFromThemeId(List<String> themeIds) async {
    listings.clear();

    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update(["detail"]);
    int successCount = 0;
    for (int i = 0; i < themeIds.length; i++) {
      if (box.hasData('theme_${themeIds[i]}')) {
        listings.add(AudioEntry.fromJson(box.read('theme_${themeIds[i]}')));
        successCount++;
        continue;
      }

      if (successCount == 0 && i + 1 < themeIds.length) {
        status = RxStatus.error("Something went wrong");
        update(["detail"]);
      }
    }
    if (listings.isEmpty) {
      status = RxStatus.empty();
    } else {
      status = RxStatus.success();
    }
    update(["detail"]);
  }

  Future playCurrentListing() async {
    if (listings.isNotEmpty) {
      Get.find<DashboardController>().init(listings);
    }
  }
}
