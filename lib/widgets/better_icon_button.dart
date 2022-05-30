import 'package:flutter/material.dart';

class BetterButton extends StatelessWidget {
  const BetterButton({Key? key, this.icon, this.onPressed}) : super(key: key);
  final IconData? icon;
  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50),
      child: Material(
        child: InkWell(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Icon(
              icon,
            ),
          ),
          onTap: onPressed,
        ),
      ),
    );
  }
}
