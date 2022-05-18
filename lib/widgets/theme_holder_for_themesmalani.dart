import 'package:anime_themes_player/models/themesmalani.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ThemeHolderForThemesMalani extends StatelessWidget {
  const ThemeHolderForThemesMalani({Key? key, this.themesMalAni})
      : super(key: key);
  final ThemesMalAni? themesMalAni;
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
                        themesMalAni!.name,
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
                              themesMalAni!.season,
                              overflow: TextOverflow.fade,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              themesMalAni!.year.toString(),
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
