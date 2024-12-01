import 'package:flutter/material.dart';

InputDecoration getTextFieldDecoration(BuildContext context, String label) {
  return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 16),
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).hintColor,
      ),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).hintColor,
          ),
          borderRadius: BorderRadius.circular(28.0)),
      border: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).hintColor,
          ),
          borderRadius: BorderRadius.circular(28.0)));
}
