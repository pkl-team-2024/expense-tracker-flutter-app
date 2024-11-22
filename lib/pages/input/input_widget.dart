import 'package:finance_tracker/helper/formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class buildLaporanPreview extends StatelessWidget {
  const buildLaporanPreview({
    super.key,
    required Map<String, dynamic> laporan,
  }) : _laporan = laporan;

  final Map<String, dynamic> _laporan;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        _laporan["isIncome"] ? Icons.arrow_downward : Icons.arrow_upward,
        size: 32,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      tileColor: _laporan["isIncome"]
          ? Colors.green.withOpacity(0.2)
          : Colors.red.withOpacity(0.2),
      iconColor: _laporan["isIncome"] ? Colors.green : Colors.red,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _laporan["image"] != null
              ? Row(
                  children: [
                    Icon(
                      Icons.image_rounded,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 4)
                  ],
                )
              : const SizedBox(),
          Text(
            _laporan["category"],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      subtitle: Text(formatRupiah(_laporan["amount"])),
      trailing: Text(
        formatDate(_laporan["date"]),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}

SizedBox buildFullWidthButton(
  BuildContext context,
  String text, {
  bool primary = true,
  Function()? onButtonPressed,
  Color? colorOverride,
  Color? textColorOverride,
  IconData? icon,
}) {
  Color getTextColor() {
    return textColorOverride ??
        (primary
            ? Theme.of(context).colorScheme.onInverseSurface
            : Theme.of(context).colorScheme.onSurface);
  }

  return SizedBox(
    width: double.infinity,
    child: CupertinoButton(
      color: colorOverride ??
          (primary ? Theme.of(context).colorScheme.inverseSurface : null),
      onPressed: onButtonPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(color: getTextColor()),
          ),
          if (icon != null) const SizedBox(width: 8),
          if (icon != null)
            Icon(
              icon,
              color: getTextColor(),
              size: 20,
            ),
        ],
      ),
    ),
  );
}
