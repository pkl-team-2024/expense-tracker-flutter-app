import 'package:flutter/material.dart';

InputDecoration InputModernStyle({
  required BuildContext context,
  String? labelText,
  String? hintText,
  Widget? prefixIcon,
  TextStyle? labelStyle,
  TextStyle? hintStyle,
  InputBorder? enabledBorder,
  InputBorder? focusedBorder,
  InputDecoration? additionalDecoration,
}) {
  final baseDecoration = InputDecoration(
    labelStyle: labelStyle ??
        const TextStyle(
          // color: Colors.blueAccent,
          fontWeight: FontWeight.bold,
        ),
    hintStyle: hintStyle ??
        const TextStyle(
          color: Colors.grey,
          fontStyle: FontStyle.italic,
        ),
    enabledBorder: enabledBorder ??
        OutlineInputBorder(
          borderSide: BorderSide(
              color: Theme.of(context).colorScheme.inverseSurface, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
    focusedBorder: focusedBorder ??
        OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue, width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
  );

  return additionalDecoration != null
      ? baseDecoration.copyWith(
          labelText: additionalDecoration.labelText ?? labelText,
          hintText: additionalDecoration.hintText ?? hintText,
          prefixIcon: additionalDecoration.prefixIcon ?? prefixIcon,
          labelStyle: additionalDecoration.labelStyle ?? labelStyle,
          hintStyle: additionalDecoration.hintStyle ?? hintStyle,
          enabledBorder: additionalDecoration.enabledBorder ?? enabledBorder,
          focusedBorder: additionalDecoration.focusedBorder ?? focusedBorder,
        )
      : baseDecoration;
}
