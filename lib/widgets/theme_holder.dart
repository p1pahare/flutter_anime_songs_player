import 'package:anime_themes_player/utilities/values.dart';
import 'package:flutter/material.dart';

import '../models/democat.dart';

class ThemeHolder extends StatelessWidget {
  const ThemeHolder({Key? key, this.cat}) : super(key: key);
  final DemoCat? cat;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [Image.network(cat?.url ?? Values.errorImage)],
      ),
    );
  }
}
