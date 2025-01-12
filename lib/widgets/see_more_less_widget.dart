import 'dart:math';

import 'package:float_column/float_column.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SeeMoreLessWidget extends StatefulWidget {
  final String? textData;

  const SeeMoreLessWidget({
    super.key,
    required this.textData,
  });

  @override
  State<SeeMoreLessWidget> createState() => _SeeMoreLessWidgetState();
}

class _SeeMoreLessWidgetState extends State<SeeMoreLessWidget> {
  bool expanded = false;
  @override
  Widget build(BuildContext context) {
    if (widget.textData == null || widget.textData?.isEmpty == true) {
      return const SizedBox.shrink();
    }
    String text = "";
    if (expanded) {
      text = widget.textData ?? "";
    } else {
      text = (widget.textData
              ?.substring(0, min(130, (widget.textData?.length ?? 0)))) ??
          "";
      text += "...";
    }
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 12.0,
          left: 14,
          right: 14,
        ),
        child: InkWell(
            onTap: () {
              setState(() {
                expanded = !expanded;
              });
            },
            child: FloatColumn(
              children: [
                Floatable(
                  float: FCFloat.right,
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: context.width * 0.25,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.shuffle,
                          ),
                        ),
                        CircleAvatar(
                          radius: 24,
                          child: IconButton(
                            iconSize: 28,
                            onPressed: () {},
                            icon: const Icon(
                              Icons.play_arrow_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                WrappableText(
                  text: TextSpan(
                    text: "",
                    children: [
                      TextSpan(
                        text: text,
                      ),
                      const WidgetSpan(
                        child: SizedBox(
                          width: 3.0,
                        ),
                      ),
                      WidgetSpan(
                        child: Icon(
                          (!expanded)
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 17.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
