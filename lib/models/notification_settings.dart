// Simply Athan - prayer times and Qibla app.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
