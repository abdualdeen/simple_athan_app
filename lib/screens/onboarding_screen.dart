import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../controllers/theme_controller.dart';
import '../theme/app_theme.dart';
import 'manual_location_screen.dart';

/// First-launch intro that sets up prayer reminders, the location and the
/// theme before the home screen is shown.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final PrayerTimesController controller;
  final ThemeController themeController;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const int _stepCount = 4;

  int _step = 0;
  bool _isLocating = false;

  void _next() {
    if (_step + 1 >= _stepCount) {
      widget.controller.completeOnboarding();
      return;
    }
    setState(() => _step++);
  }

  Future<void> _enableNotifications() async {
    await widget.controller.setNotificationsEnabled(true);
    if (mounted) _next();
  }

  Future<void> _disableNotifications() async {
    await widget.controller.setNotificationsEnabled(false);
    if (mounted) _next();
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
              _ProgressDots(step: _step, count: _stepCount),
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
    switch (_step) {
      case 0:
        return _WelcomeStep(onGetStarted: _next);
      case 1:
        return _NotificationsStep(
          onEnable: _enableNotifications,
          onNotNow: _disableNotifications,
        );
      case 2:
        return _LocationStep(
          controller: widget.controller,
          isLocating: _isLocating,
          onUseDevice: _useDeviceLocation,
          onEnterManually: _enterManually,
        );
      case 3:
        return _ThemeStep(
          themeController: widget.themeController,
          onContinue: _next,
        );
    }
    throw StateError('Unknown onboarding step: $_step');
  }
}

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
