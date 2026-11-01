import 'package:flutter/foundation.dart';

import '../services/settings_store.dart';
import '../theme/app_theme.dart';

/// Owns the selected app theme and persists it.
class ThemeController extends ChangeNotifier {
  ThemeController({required SettingsStore settingsStore})
    : this._(settingsStore);

  ThemeController._(this._settingsStore);

  final SettingsStore _settingsStore;
  AppThemeChoice _choice = AppThemeChoice.emerald;
  bool _disposed = false;

  AppThemeChoice get choice => _choice;

  Future<void> initialize() async {
    try {
      _choice = await _settingsStore.loadTheme();
    } catch (error) {
      debugPrint('Failed to load theme: $error');
    }
    _notify();
  }

  Future<void> select(AppThemeChoice choice) async {
    if (_choice == choice) return;
    _choice = choice;
    _notify();
    await _settingsStore.saveTheme(choice);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
