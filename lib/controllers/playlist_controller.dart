import 'dart:developer';
import 'dart:math' as math;

import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistController extends GetxController {
  NetworkCalls networkCalls = NetworkCalls();
  RxList<Map<int, String>> playlists = RxList.empty();
  GetStorage box = GetStorage();
  List<AnimethemesMain> listings = [];
  RxStatus status = RxStatus.empty();
  final TextEditingController playlistName = TextEditingController();
  initialize() {
    box = GetStorage();
    List<String> stringPlaylists = (box.read<List<dynamic>>('playlists') ?? [])
        .map((e) => e.toString())
        .toList();
    for (String i in stringPlaylists) {
      playlists.add(decodePlayListFromString(i));
    }
    playlists.refresh();
    log("initialized");
    update();
  }

  Map<int, String> decodePlayListFromString(String encodedPlaylist) {
    Map<int, String> _playlist1 = {
      0: encodedPlaylist.substring(0, 5),
      1: encodedPlaylist.substring(5, 90),
      for (int i = 2; i <= 1000; i++)
        i: encodedPlaylist.substring(90 + ((i - 2) * 7), 90 + ((i - 1) * 7))
    };
    return _playlist1;
  }

  String getReadablePlaylistName(String asciiName) {
    String playlistName = '';
    for (int i = 0; i < asciiName.length - 1; i += 2) {
      int charcode = int.tryParse(asciiName.substring(i, i + 2)) ?? 0;
      if (charcode == 0) {
        continue;
      }
      log("decoded ->" + String.fromCharCode(charcode));
      playlistName += String.fromCharCode(charcode);
    }
    return playlistName;
  }

  String songCount(Map<int, String> playlist) =>
      "${(playlist.values.where((element) => element != "0000000").length - 2)} Songs";
  String encodePlayListToString(Map<int, String> encodedPlaylist) {
    String ecodedString = '';
    for (String part in encodedPlaylist.values) {
      ecodedString += part;
    }
    return ecodedString;
  }

  void onClear() {
    if (playlistName.text.isNotEmpty) {
      playlistName.clear();
    }
    update();
  }

  void onCreatePlaylist() {
    Get.focusScope?.unfocus();
    createPlayList(playlistName.text);
    if (playlistName.text.isNotEmpty) {
      playlistName.clear();
    }
    update();
  }

  void createPlayList(String name) {
    String playlistId = (10000 + playlists.length + 1).toString();
    log('${math.Random().nextInt(79999) + 20000}');
    String playlistName = '';

    if (!validPlaylist.hasMatch(name)) {
      showMessage("Playlist name can only be alphanumeric");
      return;
    }
    if (name.length > 41) {
      showMessage("Playlist length must be less than 40");
      return;
    }
    for (int i = 0; i < 42; i++) {
      if (i >= name.length) {
        playlistName = playlistName + '00';
        continue;
      }

      log(' ASCII value of ${name[i]} is ${name.toUpperCase().codeUnitAt(i)}');
      playlistName = playlistName + '${name.toUpperCase().codeUnitAt(i)}';
    }
    playlists.add({
      0: playlistId,
      1: playlistName,
      for (int i = 2; i <= 1001; i++) i: '0000000'
    });
    writePlayliststoBox();
  }

  addToPlayList(String playlistId, String themeId) async {
    if (playlistIsFull(playlistId)) {
      showMessage(
          "This Playlist is full, Please add this track to another list");
      return;
    }
    int playlistIndex =
        playlists.indexWhere((element) => element[0] == playlistId);
    int emptyIndex = playlists[playlistIndex]
        .entries
        .firstWhere((element) => element.value == '0000000')
        .key;
    int existingId = playlists[playlistIndex]
        .entries
        .toList()
        .indexWhere((element) => element.value == themeId.padLeft(7));

    if (existingId != -1) {
      showMessage(
          "This theme already present in the playlist '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}'.");
      return;
    }
    playlists[playlistIndex][emptyIndex] = themeId.padLeft(7, '0');
    playlists.refresh();
    await writePlayliststoBox();
    showMessage(
        "Song added to the playlist '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}' Successfully.");
  }

  deleteFromPlayList(String playlistId, String themeId) async {
    if (playlistIsFull(playlistId)) {
      showMessage(
          "This Playlist is full, Please add this track to another list");
      return;
    }
    int playlistIndex =
        playlists.indexWhere((element) => element[0] == playlistId);
    int emptyIndex = playlists[playlistIndex]
        .entries
        .firstWhere((element) => element.value == themeId.padLeft(7))
        .key;
    playlists[playlistIndex][emptyIndex] = "0000000";
    playlists.refresh();
    await writePlayliststoBox();
    showMessage(
        "Song removed from the playlist '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}' Successfully.");
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
        confirmTextColor: Get.theme.textTheme.bodyText2!.color,
        content: Text(
            "Do you really want to delete playlist '${getReadablePlaylistName(playList[1] ?? '')}' with ${songCount(playList)} ?"),
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
        'playlists',
        playlists
            .map<String>((element) => encodePlayListToString(element))
            .toList());
    update();
  }

  themesFromThemeId(List<String> themeIds) async {
    listings.clear();

    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update(["detail"]);
    int successCount = 4;
    for (int i = 0; i < themeIds.length; i++) {
      int currId = int.tryParse(themeIds[i]) ?? 0;
      if (currId == 0) continue;
      ApiResponse apiResponse = await networkCalls.loadAnimetheme(currId);
      if (apiResponse.status) {
        listings.add(AnimethemesMain.fromJson(apiResponse.data['animetheme']));
      } else {
        successCount--;
      }
      if (successCount == 0) {
        status = RxStatus.error(apiResponse.message);
        update(["detail"]);
        break;
      }
    }

    if (listings.isEmpty) {
      status = RxStatus.empty();
    } else {
      status = RxStatus.success();
    }
    update(["detail"]);
  }
}
