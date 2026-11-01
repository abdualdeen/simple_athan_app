import 'package:flutter/foundation.dart';

import 'prayer.dart';

/// A single prayer reminder ready to be handed to the notification plugin.
@immutable
class PrayerNotification {
  const PrayerNotification({
    required this.id,
    required this.prayer,
    required this.time,
    required this.title,
    required this.body,
  });

  final int id;
  final PrayerId prayer;
  final DateTime time;
  final String title;
  final String body;
}
