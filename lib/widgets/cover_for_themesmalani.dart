import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CoverForThemesMalani extends StatelessWidget {
  const CoverForThemesMalani({Key? key, this.themesMalAni}) : super(key: key);
  final ThemesMalAni? themesMalAni;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width - 90,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              themesMalAni!.name,
              maxLines: 2,
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              "${themesMalAni!.season} ${themesMalAni!.year}",
              overflow: TextOverflow.fade,
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
