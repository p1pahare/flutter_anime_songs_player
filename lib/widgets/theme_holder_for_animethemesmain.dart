import 'package:anime_themes_player/models/animethemes_main.dart';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeHolderForAnimethemesMain extends StatelessWidget {
  const ThemeHolderForAnimethemesMain({Key? key, this.animethemesMain})
      : super(key: key);
  final AnimethemesMain? animethemesMain;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Get.width - 50,
      child: Card(
        elevation: 3.5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () {},
          child: Row(
            children: [
              Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(7),
                          bottomLeft: Radius.circular(7))),
                  width: Get.width * 0.32,
                  child: Image.network(
                    animethemesMain?.anime.images.first.link ??
                        Values.errorImage,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProcess) =>
                        loadingProcess == null
                            ? child
                            : const ProgressIndicatorButton(),
                    cacheHeight: 160,
                    cacheWidth: 160,
                  )),
              Container(
                width: 0.3333,
                height: 150,
                margin: const EdgeInsets.only(right: 20),
                color: Colors.brown,
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        animethemesMain!.song.title,
                        maxLines: 2,
                        overflow: TextOverflow.fade,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              animethemesMain!.anime.year.toString(),
                              overflow: TextOverflow.fade,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              animethemesMain!.song.artists.toString(),
                              overflow: TextOverflow.fade,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {}, icon: const Icon(Icons.more_vert_outlined))
            ],
          ),
        ),
      ),
    );
  }
}
