import 'package:flutter/material.dart';

InputDecoration getTextFieldDecoration(BuildContext context, String label) {
  return InputDecoration(
      contentPadding: const EdgeInsets.only(left: 16),
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).hintColor,
      ),
      errorMaxLines: 2,
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

InputDecoration getOldTextFieldDecoration(BuildContext context, String label,
    {Widget? suffix}) {
  return InputDecoration(
      hintText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Theme.of(context).hintColor,
          ),
          borderRadius: BorderRadius.circular(4.0)),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          color: Theme.of(context).hintColor,
        ),
        borderRadius: BorderRadius.circular(4.0),
      ),
      suffixIcon: suffix);
}
