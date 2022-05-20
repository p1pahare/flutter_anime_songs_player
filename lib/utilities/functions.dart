import 'package:flutter/material.dart';
import 'package:get/get.dart';

String percentEncode(String input) {
  // Do initial percentage encoding of using Uri.encodeComponent()
  input = Uri.encodeComponent(input);

  // Percentage encode characters ignored by Uri.encodeComponent()
  input = input.replaceAll('-', '%2D');
  input = input.replaceAll('_', '%5F');
  input = input.replaceAll('.', '%2E');
  input = input.replaceAll('!', '%21');
  input = input.replaceAll('~', '%7E');
  input = input.replaceAll('*', '%2A');
  input = input.replaceAll('\'', '%5C');
  input = input.replaceAll('(', '%28');
  input = input.replaceAll(')', '%29');

  return input;
}

final validPlaylist = RegExp(r'^[a-zA-Z0-9 ]+$');

showMessage(String message) {
  Get.showSnackbar(GetSnackBar(
    message: message,
    duration: const Duration(seconds: 4),
    mainButton: IconButton(
      icon: const Icon(
        Icons.cancel_outlined,
        color: Colors.white,
      ),
      onPressed: () {
        Get.back();
      },
    ),
  ));
}
