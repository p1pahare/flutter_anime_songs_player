import 'dart:ui';
import 'package:anime_themes_player/utilities/values.dart';
import 'package:anime_themes_player/widgets/progress_indicator_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BlurredImageBackground extends StatelessWidget {
  final String imagePath;

  const BlurredImageBackground({super.key, required this.imagePath});
  static const posterWidth = 120.0;
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
           SizedBox(
          width: posterWidth,
          height: double.infinity,
          child: _buildImage(BoxFit.cover),
        ),
        ],
      ),
    );
  }

  Widget _buildImage(BoxFit fit) {
    if (imagePath == Values.noImage) {
      return Image.asset(imagePath, fit: fit);
    }
    return Image.network(
      imagePath,
      fit: fit,
      errorBuilder: (context, _, __) => Image.asset(Values.noImage, fit: fit),
      loadingBuilder: (context, child, loading) => 
          loading == null ? child : const Center(child: ProgressIndicatorButton()),
    );
  }
}
