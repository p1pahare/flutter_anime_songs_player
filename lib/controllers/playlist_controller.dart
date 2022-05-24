import 'dart:developer';
import 'dart:math' as math;

import 'package:anime_themes_player/controllers/search_controller.dart';
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:flutter/material.dart';
import 'package:anime_themes_player/models/anime_main.dart' as animemain;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class PlaylistController extends GetxController {
  NetworkCalls networkCalls = NetworkCalls();
  RxList<Map<int, String>> playlists = RxList.empty();
  GetStorage box = GetStorage();
  RxList<Map<String, dynamic>> listings = RxList.empty();
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
      for (int i = 2; i <= 1001; i++)
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
      // log("decoded ->" + String.fromCharCode(charcode));
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

  addToPlayList(String playlistId, String themeId,
      Map<String, dynamic> songmetadata) async {
    if (playlistIsFull(playlistId)) {
      showMessage(
          "This Playlist is full, Please add this track to another list");
      return;
    }
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
      showMessage(
          "This theme already present in the playlist '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}'.");
      return;
    }
    playlists[playlistIndex][emptyIndex] = paddedThemeId;
    for (MapEntry me in playlists[playlistIndex].entries) {
      if (me.value != '0000000') log("${me.key}  _______:______ ${me.value}");
    }
    playlists.refresh();
    await writePlayliststoBox();
    await writeSongMetaDataToBox(paddedThemeId, songmetadata);
    showMessage(
        "Song added to the playlist '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}' Successfully.");
  }

  Future deleteFromPlayList(String playlistId, String themeId) async {
    if (playlistIsFull(playlistId)) {
      showMessage(
          "This Playlist is full, Please add this track to another list");
      return;
    }
    int playlistIndex =
        playlists.indexWhere((element) => element[0] == playlistId);
    if (playlistIndex == -1) {
      showMessage(
          "No such playlist found '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}'.");
      return;
    }
    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update(["detail"]);
    final themeId1 = themeId.padLeft(7, '0');
    log(playlists[playlistIndex].containsValue(themeId1).toString());
    int emptyIndex = playlists[playlistIndex]
        .entries
        .firstWhere((element) => element.value == themeId1,
            orElse: () => MapEntry(-1, themeId.padLeft(7, '0')))
        .key;
    if (playlistIndex == -1 || emptyIndex == -1) {
      showMessage(
          "No such entry found '${getReadablePlaylistName(playlists[playlistIndex][1] ?? '')}'.");
      return;
    }
    playlists[playlistIndex][emptyIndex] = "0000000";
    listings.removeWhere(
        (element) => element['id'] == int.tryParse(themeId).toString());
    playlists.refresh();
    await writePlayliststoBox();
    if (listings.isEmpty) {
      status = RxStatus.empty();
    } else {
      status = RxStatus.success();
    }
    update(['detail']);
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

  Future<void> writeSongMetaDataToBox(
      String themeId, Map<String, dynamic> songmetadata) async {
    await box.write('theme_$themeId', songmetadata);
  }

  metadataFromThemeId(List<String> themeIds) async {
    listings.clear();

    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update(["detail"]);
    int successCount = 4;
    for (int i = 0; i < themeIds.length; i++) {
      if (box.hasData('theme_${themeIds[i]}')) {
        listings.add(box.read('theme_${themeIds[i]}'));
        continue;
      }

      final Map<String, dynamic>? songmetadata =
          await getMetaDataFromThemeID(themeIds[i]);
      if (songmetadata != null) {
        await writeSongMetaDataToBox(themeIds[i], songmetadata);
      } else {
        successCount--;
      }
      if (successCount == 0) {
        status = RxStatus.error("Something went wrong");
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

  Future<Map<String, dynamic>?> getMetaDataFromThemeID(String themeId) async {
    int currId = int.tryParse(themeId) ?? 0;
    if (currId == 0) return null;

    ApiResponse apiResponse = await networkCalls.loadAnimetheme(currId);
    if (apiResponse.status) {
      final AnimethemesMain animethemesMain =
          AnimethemesMain.fromJson(apiResponse.data['animetheme']);
      animemain.AnimeMain? animeMain = await Get.find<SearchController>()
          .slugToMalId(animethemesMain.anime.slug);
      if (animeMain == null) return null;
      log("${animethemesMain.anime.slug} malId ${animeMain.resources.first.externalId} themeId ${animethemesMain.slug}${animethemesMain.animethemeentries.first.version == 0 ? '' : ' V${animethemesMain.animethemeentries.first.version}'} ${animethemesMain.animethemeentries.first.videos.first.link}");

      log("malId ${animeMain.resources.first.externalId} themeId ${animethemesMain.slug}${animethemesMain.animethemeentries.first.version == 0 ? '' : ' V${animethemesMain.animethemeentries.first.version}'} ${animethemesMain.animethemeentries.first.videos.first.link}");
      ApiResponse mp3link = await Get.find<SearchController>().webmToMp3(
          animeMain.resources.first.externalId.toString(),
          "${animethemesMain.slug}${animethemesMain.animethemeentries.first.version == 0 ? '' : ' V${animethemesMain.animethemeentries.first.version}'}",
          animethemesMain.animethemeentries.first.videos.first.link);
      final AudioEntry _audioEntry = AudioEntry(
          album: animeMain.name,
          title: animethemesMain.song.title,
          url: mp3link.status
              ? mp3link.data
              : animethemesMain.animethemeentries.first.videos.first.link,
          urld: animeMain.images.isEmpty ? '' : animeMain.images.first.link);
      final Map<String, dynamic> songmetadata = {
        'id': themeId,
        'anime': animeMain.toJson(),
        'animetheme': animethemesMain.toJson(),
        'animethemeentry': animethemesMain.animethemeentries.first.toJson(),
        'audioentry': _audioEntry.toJson()
      };
      return songmetadata;
    } else {
      return null;
    }
  }
}
