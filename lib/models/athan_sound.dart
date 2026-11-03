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
