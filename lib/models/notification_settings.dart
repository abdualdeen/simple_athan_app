import 'package:flutter/foundation.dart';

import 'athan_sound.dart';
import 'prayer.dart';

/// Which prayers should raise an adhan notification.
@immutable
class NotificationSettings {
  const NotificationSettings({
    this.enabled = true,
    this.muted = const <PrayerId>{},
    this.sound = AthanSound.system,
  });

  /// Master switch for all prayer notifications.
  final bool enabled;

  /// Prayers the user has individually silenced.
  final Set<PrayerId> muted;

  /// Adhan sound played by notifications.
  final AthanSound sound;

  bool isEnabledFor(PrayerId id) => enabled && !muted.contains(id);

  NotificationSettings copyWith({
    bool? enabled,
    Set<PrayerId>? muted,
    AthanSound? sound,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      muted: muted ?? this.muted,
      sound: sound ?? this.sound,
    );
  }

  NotificationSettings togglePrayer(PrayerId id) {
    final Set<PrayerId> next = Set<PrayerId>.of(muted);
    if (!next.add(id)) next.remove(id);
    return copyWith(muted: next);
  }
}
