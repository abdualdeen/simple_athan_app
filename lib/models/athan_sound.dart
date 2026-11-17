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

/// The adhan sounds bundled with the app.
///
/// Labels mirror the file names found in `lib/sounds`.
enum AthanSound {
  /// The notification sound chosen by the operating system.
  system('System default'),

  /// `lib/sounds/Makkah - Ali Mullah.mp3`
  makkahAliMullah('Makkah - Ali Mullah'),

  /// `lib/sounds/Madina - Muhammad Qassas.mp3`
  madinaMuhammadQassas('Madina - Muhammad Qassas');

  const AthanSound(this.label);

  /// Name shown in the settings UI.
  final String label;

  /// Android raw resource name: the file in `res/raw` without extension.
  String get androidResource => switch (this) {
    AthanSound.system => '',
    AthanSound.makkahAliMullah => 'makkah_ali_mullah',
    AthanSound.madinaMuhammadQassas => 'madina_muhammad_qassas',
  };

  /// iOS/macOS bundle file name, including extension.
  String get darwinFile => switch (this) {
    AthanSound.system => '',
    AthanSound.makkahAliMullah => 'makkah_ali_mullah.mp3',
    AthanSound.madinaMuhammadQassas => 'madina_muhammad_qassas.mp3',
  };

  static AthanSound fromName(String? name) => AthanSound.values.firstWhere(
    (AthanSound sound) => sound.name == name,
    orElse: () => AthanSound.system,
  );
}
