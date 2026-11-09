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

import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/athan_sound.dart';
import '../services/sound_preview_service.dart';
import '../theme/app_theme.dart';
import 'manual_location_screen.dart';

/// First-launch intro that sets up prayer reminders, the location and the
/// theme before the home screen is shown.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.controller,
    required this.themeController,
    this.soundPreviewService = const PlatformSoundPreviewService(),
  });

  final PrayerTimesController controller;
  final ThemeController themeController;
  final SoundPreviewService soundPreviewService;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _step = 0;
  bool _isLocating = false;
  bool _notificationsEnabled = false;
  bool _exactAlarmsAllowed = false;
  AthanSound? _playingSound;

  @override
  void initState() {
    super.initState();
    widget.soundPreviewService.setCompletionHandler(_onPreviewComplete);
  }

  @override
  void dispose() {
    unawaited(widget.soundPreviewService.stop());
    widget.soundPreviewService.setCompletionHandler(null);
    super.dispose();
  }

  /// The steps of the intro. The alarms and adhan sound steps only exist when
  /// the user enabled reminders on the notifications screen, and the alarms
  /// step is skipped when the platform already allows exact scheduling.
  List<_OnboardingStep> get _steps => <_OnboardingStep>[
    _OnboardingStep.welcome,
    _OnboardingStep.notifications,
    if (_notificationsEnabled && !_exactAlarmsAllowed) _OnboardingStep.alarms,
    if (_notificationsEnabled) _OnboardingStep.sound,
    _OnboardingStep.location,
    _OnboardingStep.theme,
  ];

  void _next() {
    final List<_OnboardingStep> steps = _steps;
    if (_step + 1 >= steps.length) {
      widget.controller.completeOnboarding();
      return;
    }
    if (steps[_step] == _OnboardingStep.sound) {
      unawaited(widget.soundPreviewService.stop());
    }
    setState(() => _step++);
  }

  Future<void> _enableNotifications() async {
    await widget.controller.setNotificationsEnabled(true);
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = true;
      _exactAlarmsAllowed = widget.controller.exactAlarmsAllowed;
    });
    _next();
  }

  Future<void> _requestExactAlarms() async {
    await widget.controller.requestExactAlarms();
    if (!mounted) return;
    setState(() => _exactAlarmsAllowed = widget.controller.exactAlarmsAllowed);
    _next();
  }

  Future<void> _disableNotifications() async {
    await widget.controller.setNotificationsEnabled(false);
    if (!mounted) return;
    setState(() => _notificationsEnabled = false);
    _next();
  }

  Future<void> _togglePreview(AthanSound sound) async {
    if (_playingSound == sound) {
      setState(() => _playingSound = null);
      await widget.soundPreviewService.stop();
      return;
    }
    setState(() => _playingSound = sound);
    await widget.soundPreviewService.play(sound);
  }

  void _onPreviewComplete(AthanSound sound) {
    if (!mounted) return;
    if (_playingSound == sound) setState(() => _playingSound = null);
  }

  Future<void> _useDeviceLocation() async {
    setState(() => _isLocating = true);
    await widget.controller.refreshLocation();
    if (!mounted) return;
    setState(() => _isLocating = false);
    if (widget.controller.location.isResolved) _next();
  }

  Future<void> _enterManually() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ManualLocationScreen(controller: widget.controller),
      ),
    );
    if (!mounted) return;
    if (widget.controller.location.isResolved) _next();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _ProgressDots(step: _step, count: _steps.length),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_step),
                    child: _buildStep(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_steps[_step]) {
      case _OnboardingStep.welcome:
        return _WelcomeStep(onGetStarted: _next);
      case _OnboardingStep.notifications:
        return _NotificationsStep(
          onEnable: _enableNotifications,
          onNotNow: _disableNotifications,
        );
      case _OnboardingStep.alarms:
        return _AlarmsStep(onAllow: _requestExactAlarms, onNotNow: _next);
      case _OnboardingStep.sound:
        return _SoundStep(
          controller: widget.controller,
          playingSound: _playingSound,
          onTogglePreview: _togglePreview,
          onContinue: _next,
        );
      case _OnboardingStep.location:
        return _LocationStep(
          controller: widget.controller,
          isLocating: _isLocating,
          onUseDevice: _useDeviceLocation,
          onEnterManually: _enterManually,
        );
      case _OnboardingStep.theme:
        return _ThemeStep(
          themeController: widget.themeController,
          onContinue: _next,
        );
    }
  }
}

enum _OnboardingStep { welcome, notifications, alarms, sound, location, theme }

/// Icon, title and description shared by the intro steps.
class _StepHeader extends StatelessWidget {
  const _StepHeader({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: palette.primary.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: palette.primary, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: palette.ink,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          description,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: palette.inkMuted, height: 1.45),
        ),
      ],
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  const _WelcomeStep({required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepHeader(
          icon: Icons.nightlight_round,
          title: 'Welcome to Athan',
          description:
              'Prayer times for your location, the Qibla direction and '
              'gentle adhan reminders.',
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: onGetStarted,
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Get started'),
        ),
      ],
    );
  }
}

class _NotificationsStep extends StatelessWidget {
  const _NotificationsStep({required this.onEnable, required this.onNotNow});

  final VoidCallback onEnable;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepHeader(
          icon: Icons.notifications_active_outlined,
          title: 'Prayer reminders',
          description:
              'Get an adhan notification for each prayer time. You can '
              'change this any time in Settings.',
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: onEnable,
          icon: const Icon(Icons.notifications_active_rounded, size: 18),
          label: const Text('Enable notifications'),
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onNotNow,
          style: TextButton.styleFrom(foregroundColor: palette.label),
          child: const Text('Not now'),
        ),
      ],
    );
  }
}

class _AlarmsStep extends StatelessWidget {
  const _AlarmsStep({required this.onAllow, required this.onNotNow});

  final VoidCallback onAllow;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepHeader(
          icon: Icons.alarm_rounded,
          title: 'Allow alarms & reminders',
          description:
              'Athan needs permission to schedule exact alarms so prayer '
              'notifications arrive on time. Without it, Android may delay '
              'them by several minutes to save battery.',
        ),
        const SizedBox(height: 32),
        FilledButton.icon(
          onPressed: onAllow,
          icon: const Icon(Icons.alarm_rounded, size: 18),
          label: const Text('Allow exact alarms'),
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onNotNow,
          style: TextButton.styleFrom(foregroundColor: palette.label),
          child: const Text('Not now'),
        ),
      ],
    );
  }
}

class _SoundStep extends StatelessWidget {
  const _SoundStep({
    required this.controller,
    required this.playingSound,
    required this.onTogglePreview,
    required this.onContinue,
  });

  final PrayerTimesController controller;
  final AthanSound? playingSound;
  final void Function(AthanSound sound) onTogglePreview;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepHeader(
          icon: Icons.music_note_outlined,
          title: 'Athan sound',
          description:
              'Choose what the prayer reminder sounds like. Tap the play '
              'button to hear each one.',
        ),
        const SizedBox(height: 24),
        ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? _) {
            final AthanSound selected = controller.notifications.sound;
            return Column(
              children: <Widget>[
                for (final AthanSound sound in AthanSound.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _SoundRow(
                      sound: sound,
                      selected: selected == sound,
                      playing: playingSound == sound,
                      onSelect: () => controller.setNotificationSound(sound),
                      onTogglePreview: () => onTogglePreview(sound),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _SoundRow extends StatelessWidget {
  const _SoundRow({
    required this.sound,
    required this.selected,
    required this.playing,
    required this.onSelect,
    required this.onTogglePreview,
  });

  final AthanSound sound;
  final bool selected;
  final bool playing;
  final VoidCallback onSelect;
  final VoidCallback onTogglePreview;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: <Widget>[
              IconButton(
                onPressed: onTogglePreview,
                tooltip: 'Preview ${sound.label}',
                icon: Icon(
                  playing ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: playing ? palette.accentDark : palette.primary,
                ),
              ),
              Expanded(
                child: Text(
                  sound.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: palette.ink,
                  ),
                ),
              ),
              if (selected)
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: palette.primary,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationStep extends StatelessWidget {
  const _LocationStep({
    required this.controller,
    required this.isLocating,
    required this.onUseDevice,
    required this.onEnterManually,
  });

  final PrayerTimesController controller;
  final bool isLocating;
  final VoidCallback onUseDevice;
  final VoidCallback onEnterManually;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const _StepHeader(
          icon: Icons.explore_outlined,
          title: 'Your location',
          description:
              'Prayer times are calculated for your location. Choose how to '
              'set it.',
        ),
        const SizedBox(height: 28),
        ListenableBuilder(
          listenable: controller,
          builder: (BuildContext context, Widget? _) {
            final String? error = controller.locationError;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _OptionCard(
                  icon: Icons.my_location_rounded,
                  title: isLocating ? 'Locating…' : 'Use my current location',
                  subtitle:
                      'Your position is only used to calculate prayer '
                      'times.',
                  onTap: isLocating ? null : onUseDevice,
                  trailing: isLocating
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              palette.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 10),
                _OptionCard(
                  icon: Icons.edit_location_alt_outlined,
                  title: 'Enter it manually',
                  subtitle: 'Search for a city or enter coordinates.',
                  onTap: onEnterManually,
                ),
                if (error != null) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    error,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: palette.error,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: palette.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: palette.inkMuted,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeStep extends StatelessWidget {
  const _ThemeStep({required this.themeController, required this.onContinue});

  final ThemeController themeController;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Pick a theme',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w700,
            color: palette.ink,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You can change this later in Settings.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: palette.inkMuted),
        ),
        const SizedBox(height: 20),
        ListenableBuilder(
          listenable: themeController,
          builder: (BuildContext context, Widget? _) {
            return Column(
              children: <Widget>[
                for (final AppThemeChoice choice in AppThemeChoice.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ThemeRow(
                      choice: choice,
                      selected: themeController.choice == choice,
                      onTap: () => themeController.select(choice),
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onContinue,
          style: FilledButton.styleFrom(
            backgroundColor: palette.primary,
            foregroundColor: palette.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: const Text('Continue'),
        ),
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final AppThemeChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final AppPalette swatch = AppPalettes.forChoice(choice);
    return Material(
      color: palette.surface,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: <Widget>[
              _SwatchDot(color: swatch.primary),
              const SizedBox(width: 6),
              _SwatchDot(color: swatch.accent),
              const SizedBox(width: 6),
              _SwatchDot(
                color: swatch.background,
                bordered: swatch.brightness == Brightness.light,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  choice.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: palette.ink,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: palette.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwatchDot extends StatelessWidget {
  const _SwatchDot({required this.color, this.bordered = false});

  final Color color;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: bordered
            ? Border.all(color: context.palette.inkMuted.withValues(alpha: 0.3))
            : null,
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step, required this.count});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for (int i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == step ? 24 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == step
                  ? palette.primary
                  : palette.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
      ],
    );
  }
}
