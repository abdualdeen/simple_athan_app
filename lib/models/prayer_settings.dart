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

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/foundation.dart';

/// Calculation methods exposed in Settings.
enum PrayerMethod {
  muslimWorldLeague('Muslim World League'),
  moonsightingCommittee('Moonsighting Committee'),
  northAmerica('ISNA (North America)'),
  egyptian('Egyptian General Authority'),
  karachi('University of Islamic Sciences, Karachi'),
  ummAlQura('Umm al-Qura, Makkah'),
  dubai('Dubai'),
  qatar('Qatar'),
  kuwait('Kuwait'),
  singapore('Singapore'),
  turkiye('Diyanet (Turkey)'),
  tehran('Tehran');

  const PrayerMethod(this.label);

  final String label;

  CalculationParameters parameters() => switch (this) {
    PrayerMethod.muslimWorldLeague =>
      CalculationMethodParameters.muslimWorldLeague(),
    PrayerMethod.moonsightingCommittee =>
      CalculationMethodParameters.moonsightingCommittee(),
    PrayerMethod.northAmerica => CalculationMethodParameters.northAmerica(),
    PrayerMethod.egyptian => CalculationMethodParameters.egyptian(),
    PrayerMethod.karachi => CalculationMethodParameters.karachi(),
    PrayerMethod.ummAlQura => CalculationMethodParameters.ummAlQura(),
    PrayerMethod.dubai => CalculationMethodParameters.dubai(),
    PrayerMethod.qatar => CalculationMethodParameters.qatar(),
    PrayerMethod.kuwait => CalculationMethodParameters.kuwait(),
    PrayerMethod.singapore => CalculationMethodParameters.singapore(),
    PrayerMethod.turkiye => CalculationMethodParameters.turkiye(),
    PrayerMethod.tehran => CalculationMethodParameters.tehran(),
  };

  static PrayerMethod fromName(String? name) => values.firstWhere(
    (PrayerMethod method) => method.name == name,
    orElse: () => PrayerMethod.muslimWorldLeague,
  );
}

/// The school of thought used to calculate Asr (shadow length).
enum AsrMadhab {
  shafi('Standard'),
  hanafi('Hanafi');

  const AsrMadhab(this.label);

  final String label;

  String get description => switch (this) {
    AsrMadhab.shafi => 'Shafi, Maliki and Hanbali schools',
    AsrMadhab.hanafi => 'Hanafi school (later Asr)',
  };

  static AsrMadhab fromName(String? name) => values.firstWhere(
    (AsrMadhab madhab) => madhab.name == name,
    orElse: () => AsrMadhab.shafi,
  );
}

@immutable
class PrayerSettings {
  const PrayerSettings({
    this.method = PrayerMethod.muslimWorldLeague,
    this.madhab = AsrMadhab.shafi,
  });

  final PrayerMethod method;
  final AsrMadhab madhab;

  PrayerSettings copyWith({PrayerMethod? method, AsrMadhab? madhab}) {
    return PrayerSettings(
      method: method ?? this.method,
      madhab: madhab ?? this.madhab,
    );
  }
}
