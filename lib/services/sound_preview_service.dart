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
import 'package:flutter/services.dart';

import '../models/athan_sound.dart';

/// Plays short previews of the adhan sounds in the UI.
abstract interface class SoundPreviewService {
  Future<void> play(AthanSound sound);

  Future<void> stop();

  /// Registers the callback fired when native playback finishes on its own,
  /// so the UI can reset its playing indicator.
  void setCompletionHandler(void Function(AthanSound sound)? handler);
}

/// Plays previews through the platform's already-bundled sound resources.
///
/// The adhan files ship as Android raw resources and iOS bundle files for the
/// notification sounds, so previews reuse them instead of bundling a second
/// copy as Flutter assets. Platforms without an implementation (macOS) or
/// where playback fails degrade to a silent no-op.
class PlatformSoundPreviewService implements SoundPreviewService {
  const PlatformSoundPreviewService();

  static const MethodChannel _channel = MethodChannel(
    'athan_app/sound_preview',
  );

  static void Function(AthanSound sound)? _completionHandler;
  static bool _listenerRegistered = false;

  @override
  Future<void> play(AthanSound sound) async {
    _registerListener();
    try {
      await _channel.invokeMethod<void>('play', sound.name);
    } catch (error) {
      debugPrint('Sound preview playback failed: $error');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } catch (error) {
      debugPrint('Stopping the sound preview failed: $error');
    }
  }

  @override
  void setCompletionHandler(void Function(AthanSound sound)? handler) {
    _completionHandler = handler;
  }

  static void _registerListener() {
    if (_listenerRegistered) return;
    _listenerRegistered = true;
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method == 'onPreviewComplete') {
        final AthanSound sound = AthanSound.fromName(call.arguments as String?);
        _completionHandler?.call(sound);
      }
      return null;
    });
  }
}
