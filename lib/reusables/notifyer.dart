import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';

enum NotifySeverity { info, warning, error, success }

Map<NotifySeverity, Map<String, dynamic>> notifySeverityMap = {
  NotifySeverity.info: {
    'defaultLabel': 'Info',
    'color': Colors.blue,
    'icon': CupertinoIcons.info,
  },
  NotifySeverity.warning: {
    'defaultLabel': 'Warning',
    'color': Colors.orange,
    'icon': CupertinoIcons.exclamationmark_triangle,
  },
  NotifySeverity.error: {
    'defaultLabel': 'Error',
    'color': Colors.red,
    'icon': CupertinoIcons.exclamationmark_circle,
  },
  NotifySeverity.success: {
    'defaultLabel': 'Success',
    'color': Colors.green,
    'icon': CupertinoIcons.check_mark_circled,
  },
};

void notify(
  BuildContext context,
  NotifySeverity severity, {
  String? message,
  Duration? duration,
  NotificationPosition position = NotificationPosition.top,
}) {
  showOverlayNotification(
    (context) {
      return Card(
        margin: Platform.isAndroid
            ? const EdgeInsets.only(
                top: 42,
                left: 16,
                right: 16,
                bottom: 16,
              )
            : const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16,
            bottom: 16,
            left: 16,
            right: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                notifySeverityMap[severity]!['icon'],
                color: notifySeverityMap[severity]!['color'],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                message ?? notifySeverityMap[severity]!['defaultLabel'],
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    },
    duration: duration,
    position: position,
  );
}
