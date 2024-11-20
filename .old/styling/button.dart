import 'package:flutter/material.dart';

ButtonStyle ButtonModernStyle({
  required BuildContext context,
  ButtonStyle? additionalStyle,
}) {
  final baseStyle = ButtonStyle();
  return additionalStyle != null ? baseStyle.copyWith() : baseStyle;
}
