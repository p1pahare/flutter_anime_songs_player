import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:anime_themes_player/controllers/dashboard_controller.dart';
import 'package:anime_themes_player/controllers/search_controller.dart' as sc;
import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/models/api_response.dart';
import 'package:anime_themes_player/models/audio_entry.dart';
import 'package:anime_themes_player/repositories/network_calls.dart';
import 'package:anime_themes_player/utilities/functions.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:anime_themes_player/models/anime_main.dart' as animemain;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:qr_code_vision/qr_code_vision.dart';

class PlaylistController extends GetxController {
  NetworkCalls networkCalls = NetworkCalls();
  RxList<Map<int, String>> playlists = RxList.empty();
  GetStorage box = GetStorage();
  RxList<AudioEntry> listings = RxList.empty();
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
      1: encodedPlaylist.substring(5, 89),
      for (int i = 2; i <= 1001; i++)
        i: encodedPlaylist.substring(89 + ((i - 2) * 7), 89 + ((i - 1) * 7))
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

  bool containsPlaylistId(String playlistId) {
    bool exists = false;
    for (final element in playlists) {
      if (element[0] == playlistId) exists = true;
    }
    return exists;
  }

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

  importFromFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      File imageFile = File(result.files.single.path!);
      ui.Image image = await getImage(imageFile);
      final byteData =
          (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!
              .buffer
              .asUint8List();

      final qrCode = QrCode();
      qrCode.scanRgbaBytes(byteData, image.width, image.height);

      if (qrCode.location == null) {
        showMessage('No QR code found');
      } else {
        log('QR code here: ${qrCode.location}');

        if (qrCode.content == null ||
            (qrCode.content?.text.length ?? 0) < 7089) {
          showMessage('The content of the QR code could not be decoded');
        } else {
          log('This is the content: ${qrCode.content?.text}');
          await importPlaylist(qrCode.content?.text);
        }
      }
    } else {
      // User canceled the picker
    }
  }

  Future<ui.Image> getImage(File imageFile) async {
    var completer = Completer<ImageInfo>();
    var img = FileImage(imageFile);
    img
        .resolve(const ImageConfiguration())
        .addListener(ImageStreamListener((info, _) {
      completer.complete(info);
    }));
    ImageInfo imageInfo = await completer.future;
    return imageInfo.image;
  }

  Future importPlaylist(String? encodedPlaylist) async {
    final Map<int, String> playlist =
        decodePlayListFromString(encodedPlaylist!);
    while (containsPlaylistId(playlist[0] ?? '')) {
      log('${math.Random().nextInt(79999) + 10000}');
      playlist[0] = '${math.Random().nextInt(89999) + 10000}';
    }
    playlists.add(playlist);
    await writePlayliststoBox();
  }

  void createPlayList(String name) {
    String playlistId = '${math.Random().nextInt(89999) + 10000}';
    while (containsPlaylistId(playlistId)) {
      log('${math.Random().nextInt(79999) + 10000}');
      playlistId = '${math.Random().nextInt(89999) + 10000}';
    }
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
      playlistName =
          playlistName + '${name.toUpperCase().codeUnitAt(i)}'.padLeft(2, '0');
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
    bool deleteSong = (await Get.defaultDialog<bool>(
            buttonColor: Get.theme.unselectedWidgetColor,
            cancelTextColor: Get.theme.primaryColor,
            confirmTextColor: Get.theme.textTheme.bodySmall!.color,
            content: const Text(
                "Do you really want to delete this theme playlist ?"),
            onConfirm: () => Get.back(result: true, canPop: false),
            textConfirm: 'Confirm',
            onCancel: () {})) ??
        false;
    if (!deleteSong) {
      status = RxStatus.success();
      update(['detail']);
      return;
    }
    playlists[playlistIndex][emptyIndex] = "0000000";
    listings.removeWhere(
        (element) => element.id == int.tryParse(themeId).toString());
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
        confirmTextColor: Get.theme.textTheme.bodySmall!.color,
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
    update(['detail']);
  }

  metadataFromThemeId(List<String> themeIds) async {
    listings.clear();

    status = listings.isEmpty ? RxStatus.loading() : RxStatus.loadingMore();
    update(["detail"]);
    int successCount = 4;
    for (int i = 0; i < themeIds.length; i++) {
      if (box.hasData('theme_${themeIds[i]}')) {
        listings.add(AudioEntry.fromJson(box.read('theme_${themeIds[i]}')));
        continue;
      }

      final Map<String, dynamic>? songmetadata =
          await getMetaDataFromThemeID(themeIds[i]);
      if (songmetadata != null) {
        listings.add(AudioEntry.fromJson(songmetadata));
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

  Future playCurrentListing() async {
    if (listings.isNotEmpty) {
      Get.find<DashboardController>().init(listings);
    }
  }

  Future<Map<String, dynamic>?> getMetaDataFromThemeID(String themeId) async {
    int currId = int.tryParse(themeId) ?? 0;
    if (currId == 0) return null;

    ApiResponse apiResponse = await networkCalls.loadAnimetheme(currId);
    if (apiResponse.status) {
      final AnimethemesMain animethemesMain =
          AnimethemesMain.fromJson(apiResponse.data['animetheme']);

      if (Platform.isIOS || Platform.isMacOS) {
        animemain.AnimeMain? animeMain = await Get.find<sc.SearchController>()
            .slugToMalId(animethemesMain.anime.slug);
        if (animeMain == null) return null;
        log("${animethemesMain.anime.slug} malId ${animeMain.resources.first.externalId} themeId ${animethemesMain.slug}${animethemesMain.animethemeentries.first.version == 0 ? '' : ' V${animethemesMain.animethemeentries.first.version}'} ${animethemesMain.animethemeentries.first.videos.first.link}");

        log("malId ${animeMain.resources.first.externalId} themeId ${animethemesMain.slug}${animethemesMain.animethemeentries.first.version == 0 ? '' : ' V${animethemesMain.animethemeentries.first.version}'} ${animethemesMain.animethemeentries.first.videos.first.link}");
        final audioUrl = (await Get.find<sc.SearchController>().webmToMp3(
                animeMain.resources.first.externalId.toString(),
                animethemesMain.slug,
                animethemesMain.animethemeentries.first.videos.first.link))
            .data as String;
        final videoUrl = Get.find<sc.SearchController>().fileNameToUrl(
            animethemesMain.animethemeentries.first.videos.first.filename,
            mediaType: sc.MediaType.video);

        final AudioEntry _audioEntry = AudioEntry(
            id: animethemesMain.id.toString(),
            album: animeMain.name,
            title: animethemesMain.song.title,
            audioUrl: audioUrl,
            videoUrl: videoUrl,
            urlCover:
                animeMain.images.isEmpty ? '' : animeMain.images.first.link);

        return _audioEntry.toJson();
      }
      final String audioUrl = Get.find<sc.SearchController>().fileNameToUrl(
          animethemesMain.animethemeentries.first.videos.first.filename,
          mediaType: sc.MediaType.audio);
      final String videoUrl = Get.find<sc.SearchController>().fileNameToUrl(
          animethemesMain.animethemeentries.first.videos.first.filename,
          mediaType: sc.MediaType.video);
      final AudioEntry _audioEntry = AudioEntry(
          id: animethemesMain.id.toString(),
          album: animethemesMain.anime.name,
          title: animethemesMain.song.title,
          audioUrl: audioUrl,
          videoUrl: videoUrl,
          urlCover: animethemesMain.anime.images.first.link);

      return _audioEntry.toJson();
    } else {
      return null;
    }
  }
}
