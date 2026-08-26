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

String encryptText(String input) {
  final reversed = input.split('').reversed.join();
  final buffer = StringBuffer();

  for (int index = 0; index < reversed.length; index++) {
    final codeUnit = reversed.codeUnitAt(index);
    if (codeUnit < 32 || codeUnit > 126) {
      buffer.writeCharCode(codeUnit);
      continue;
    }

    final shift = index.isEven ? 3 : -3;
    final normalized = codeUnit - 32;
    final shifted = (normalized + shift) % 95;
    buffer.writeCharCode(shifted < 0 ? shifted + 95 + 32 : shifted + 32);
  }

  return buffer.toString();
}

String decryptText(String input) {
  final buffer = StringBuffer();

  for (int index = 0; index < input.length; index++) {
    final codeUnit = input.codeUnitAt(index);
    if (codeUnit < 32 || codeUnit > 126) {
      buffer.writeCharCode(codeUnit);
      continue;
    }

    final shift = index.isEven ? -3 : 3;
    final normalized = codeUnit - 32;
    final shifted = (normalized + shift) % 95;
    buffer.writeCharCode(shifted < 0 ? shifted + 95 + 32 : shifted + 32);
  }

  return buffer.toString().split('').reversed.join();
}

final validPlaylist = RegExp(r'^[a-zA-Z0-9 ]+$');

showMessage(String message) {
  Get.showSnackbar(GetSnackBar(
    message: message,
    duration: const Duration(seconds: 2),
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

Future<int?> showOptions({Map<int, String> options = const {}}) async {
  return await Get.bottomSheet<int>(
      Container(
        color: Colors.black,
        height: Get.height * 0.6,
        child: Center(
          child: ListView.builder(
            itemCount: options.length + 1,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(4),
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7)),
                  child: Material(
                    borderRadius: BorderRadius.circular(7),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(7),
                      onTap: () {
                        Get.back(
                            result: index == 0
                                ? null
                                : options.keys.toList()[index - 1]);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        child: Text(
                          index == 0 ? 'Cancel' : options[index - 1] ?? '',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
      isScrollControlled: false,
      isDismissible: false);
}
