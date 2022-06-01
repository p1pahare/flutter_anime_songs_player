import 'dart:developer';

import 'package:anime_themes_player/controllers/playlist_controller.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

class SharePlaylist extends StatelessWidget {
  const SharePlaylist({Key? key, this.playlist}) : super(key: key);
  final Map<int, String>? playlist;
  static const routeName = '/SharePlaylist';
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PlaylistController>(
      init: PlaylistController(),
      initState: (_) {},
      builder: (_) {
        String number = _.encodePlayListToString(playlist!);
        log(number);
        QrCode qrCode = QrCode(40, QrErrorCorrectLevel.L);
        qrCode.addNumeric(number);
        qrCode.make();
        return Scaffold(
          appBar: PreferredSize(
              child: AppBar(
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                centerTitle: true,
                title: Text(
                  _.getReadablePlaylistName(playlist?[1] ?? ''),
                ),
              ),
              preferredSize: const Size.fromHeight(40)),
          body: Column(
            children: [
              QrImage.withQr(
                qr: qrCode,
                version: QrVersions.max,
                errorCorrectionLevel: QrErrorCorrectLevel.L,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                size: Get.width,
              ),
              Text(DateFormat('h:m a , d MMM y').format(DateTime.now())),
              Text("${_.listings.length} Themes",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w300)),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  Values.takeAScreenShot,
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
