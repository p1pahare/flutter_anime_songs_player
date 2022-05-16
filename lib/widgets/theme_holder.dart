import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/democat.dart';

class ThemeHolder extends StatelessWidget {
  const ThemeHolder({Key? key, this.cat}) : super(key: key);
  final DemoCat? cat;
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
                    cat?.url ?? Values.errorImage,
                    height: 150,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProcess) =>
                        loadingProcess == null
                            ? child
                            : const ProgressIndicatorButton(),
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
                        cat!.id,
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
                              cat!.height + " 34343434",
                              overflow: TextOverflow.fade,
                              style: const TextStyle(fontSize: 11),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              cat!.width + "34343434",
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
