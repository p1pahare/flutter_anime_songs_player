import 'dart:ui';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlurredImageBackground extends StatelessWidget {
  final String imagePath;

  const BlurredImageBackground({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      width: context.width * 0.9,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  (Get.isDarkMode ? Colors.black : Colors.white)
                      .withOpacity(0.3), // Adjust opacity for tint
                  BlendMode.darken, // Blend mode to darken the image
                ),
                child: imagePath == Values.noImage
                    ? Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )
                    : Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (context, url, error) => Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          alignment: Alignment.center,
                        ),
                      ),
              ),
            ),
          ),
          // Centered Smaller Image
          Align(
            alignment: Alignment.centerLeft,
            child: imagePath == Values.noImage
                ? Image.asset(
                    imagePath,
                    fit: BoxFit.fill,
                    height: 160,
                    width: context.width * 0.32,
                  )
                : Image.network(
                    imagePath,
                    fit: BoxFit.fill,
                    height: 160,
                    width: context.width * 0.32,
                    alignment: Alignment.center,
                    loadingBuilder: (context, child, loadingProcess) =>
                        loadingProcess == null
                            ? child
                            : const ProgressIndicatorButton(),
                    errorBuilder: (context, url, error) => Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
