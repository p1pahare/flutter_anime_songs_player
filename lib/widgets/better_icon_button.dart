import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BetterButton extends StatelessWidget {
  const BetterButton({
    Key? key,
    this.icon,
    this.onPressed,
    this.alternate,
  }) : super(key: key);
  final IconData? icon;
  final void Function()? onPressed;
  final Widget? alternate;
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Get.isDarkMode ? Colors.white : Colors.black,
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Get.theme.colorScheme.surface,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: alternate ??
                  Icon(
                    icon,
                  ),
            ),
            onTap: onPressed,
          ),
        ),
      ),
    );
  }
}
