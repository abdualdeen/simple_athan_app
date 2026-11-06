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
