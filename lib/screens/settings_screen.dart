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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/prayer_times_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/athan_sound.dart';
import '../models/notification_settings.dart';
import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../theme/app_theme.dart';
import 'manual_location_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final PrayerTimesController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Scaffold(
      backgroundColor: palette.background,
      appBar: AppBar(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? _) {
          final AppPalette palette = context.palette;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: <Widget>[
              const _SectionLabel('LOCATION'),
              _LocationCard(controller: controller),
              const SizedBox(height: 24),
              const _SectionLabel('CALCULATION METHOD'),
              _SettingsCard(
                child: _SettingRow(
                  icon: Icons.calculate_outlined,
                  title: 'Method',
                  value: controller.settings.method.label,
                  onTap: () => _pickMethod(context),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('ASR (AFTERNOON PRAYER)'),
              _SettingsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<AsrMadhab>(
                        showSelectedIcon: false,
                        segments: const <ButtonSegment<AsrMadhab>>[
                          ButtonSegment<AsrMadhab>(
                            value: AsrMadhab.shafi,
                            label: Text('Standard'),
                          ),
                          ButtonSegment<AsrMadhab>(
                            value: AsrMadhab.hanafi,
                            label: Text('Hanafi'),
                          ),
                        ],
                        selected: <AsrMadhab>{controller.settings.madhab},
                        onSelectionChanged: (Set<AsrMadhab> selection) {
                          HapticFeedback.selectionClick();
                          controller.updateSettings(
                            controller.settings.copyWith(
                              madhab: selection.first,
                            ),
                          );
                        },
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: palette.primary,
                          selectedForegroundColor: palette.onPrimary,
                          foregroundColor: palette.ink,
                          side: BorderSide(
                            color: palette.primary.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.settings.madhab.description,
                      style: TextStyle(fontSize: 12, color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('NOTIFICATIONS'),
              _NotificationCard(
                controller: controller,
                onPickSound: () => _pickSound(context),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('APPEARANCE'),
              _SettingsCard(
                child: _SettingRow(
                  icon: Icons.palette_outlined,
                  title: 'Theme',
                  value: themeController.choice.label,
                  onTap: () => _pickTheme(context),
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('ABOUT'),
              _SettingsCard(
                child: Column(
                  children: <Widget>[
                    const _InfoRow(
                      icon: Icons.public_rounded,
                      title: 'High latitude rule',
                      value: 'Automatic',
                    ),
                    const SizedBox(height: 12),
                    const _InfoRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Calculation engine',
                      value: 'Adhan',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Prayer times are calculated astronomically for your location. '
                'Times can differ by a minute or two from your local mosque.',
                style: TextStyle(
                  fontSize: 12,
                  color: palette.inkMuted,
                  height: 1.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickMethod(BuildContext context) async {
    final AppPalette palette = context.palette;
    final PrayerMethod? selected = await showModalBottomSheet<PrayerMethod>(
      context: context,
      backgroundColor: palette.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        final AppPalette sheetPalette = sheetContext.palette;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetPalette.inkMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Calculation method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: sheetPalette.ink,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: <Widget>[
                      for (final PrayerMethod method in PrayerMethod.values)
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(
                            method.label,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: method == controller.settings.method
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sheetPalette.ink,
                            ),
                          ),
                          trailing: method == controller.settings.method
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: sheetPalette.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(sheetContext).pop(method);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await controller.updateSettings(
        controller.settings.copyWith(method: selected),
      );
    }
  }

  Future<void> _pickSound(BuildContext context) async {
    final AppPalette palette = context.palette;
    final AthanSound? selected = await showModalBottomSheet<AthanSound>(
      context: context,
      backgroundColor: palette.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        final AppPalette sheetPalette = sheetContext.palette;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetPalette.inkMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Athan sound',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: sheetPalette.ink,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: <Widget>[
                      for (final AthanSound sound in AthanSound.values)
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: Icon(
                            sound == AthanSound.system
                                ? Icons.volume_up_outlined
                                : Icons.mosque_outlined,
                            color: sheetPalette.primary,
                          ),
                          title: Text(
                            sound.label,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight:
                                  sound == controller.notifications.sound
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sheetPalette.ink,
                            ),
                          ),
                          trailing: sound == controller.notifications.sound
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: sheetPalette.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(sheetContext).pop(sound);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await controller.setNotificationSound(selected);
    }
  }

  Future<void> _pickTheme(BuildContext context) async {
    final AppPalette palette = context.palette;
    final AppThemeChoice? selected = await showModalBottomSheet<AppThemeChoice>(
      context: context,
      backgroundColor: palette.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        final AppPalette sheetPalette = sheetContext.palette;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(sheetContext).size.height * 0.75,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetPalette.inkMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: sheetPalette.ink,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                    children: <Widget>[
                      for (final AppThemeChoice choice in AppThemeChoice.values)
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          leading: _ThemeSwatch(choice: choice),
                          title: Text(
                            choice.label,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: choice == themeController.choice
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: sheetPalette.ink,
                            ),
                          ),
                          trailing: choice == themeController.choice
                              ? Icon(
                                  Icons.check_circle_rounded,
                                  color: sheetPalette.primary,
                                  size: 20,
                                )
                              : null,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            Navigator.of(sheetContext).pop(choice);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected != null) {
      await themeController.select(selected);
    }
  }
}

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.choice});

  final AppThemeChoice choice;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = AppPalettes.forChoice(choice);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            palette.primarySoft,
            palette.primary,
            palette.primaryDeep,
          ],
        ),
        border: Border.all(
          color: palette.accent.withValues(alpha: 0.7),
          width: 1.5,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: palette.inkMuted,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Material(
      color: palette.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: palette.primary.withValues(alpha: 0.07)),
      ),
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.controller});

  final PrayerTimesController controller;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final String? error = controller.locationError;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: palette.background,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: palette.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      controller.location.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.location.coordinatesLabel,
                      style: TextStyle(fontSize: 12, color: palette.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (error != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              error,
              style: TextStyle(
                fontSize: 12.5,
                color: palette.error,
                height: 1.35,
              ),
            ),
          ],
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(Icons.my_location_rounded, color: palette.primary),
            title: Text(
              'Automatic location',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            subtitle: Text(
              'Find your location every time you open the app',
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
            value: controller.useAutomaticLocation,
            onChanged: controller.isLocating
                ? null
                : (bool value) {
                    HapticFeedback.selectionClick();
                    controller.setAutomaticLocation(value);
                  },
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: controller.isLocating
                  ? null
                  : controller.refreshLocation,
              icon: controller.isLocating
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          palette.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                controller.isLocating ? 'Locating…' : 'Update from device',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: palette.primary,
                foregroundColor: palette.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      ManualLocationScreen(controller: controller),
                ),
              ),
              icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
              label: const Text('Enter location manually'),
              style: OutlinedButton.styleFrom(
                foregroundColor: palette.label,
                side: BorderSide(color: palette.label.withValues(alpha: 0.35)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: palette.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(fontSize: 12, color: palette.inkMuted),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: palette.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.controller,
    required this.onPickSound,
  });

  final PrayerTimesController controller;
  final Future<void> Function() onPickSound;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    final NotificationSettings settings = controller.notifications;
    final bool ready = controller.notificationsReady;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: Icon(
              Icons.notifications_active_outlined,
              color: palette.primary,
            ),
            title: Text(
              'Prayer reminders',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            subtitle: Text(
              'Adhan notification at each prayer time',
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
            value: settings.enabled,
            onChanged: (bool value) {
              HapticFeedback.selectionClick();
              controller.setNotificationsEnabled(value);
            },
          ),
          if (settings.enabled) ...<Widget>[
            const Divider(height: 1),
            for (final PrayerId prayer in PrayerId.values)
              if (prayer.isPrayer)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    prayer.icon,
                    size: 20,
                    color: palette.primary,
                  ),
                  title: Text(
                    prayer.label,
                    style: TextStyle(fontSize: 14, color: palette.ink),
                  ),
                  value: settings.isEnabledFor(prayer),
                  onChanged: (_) {
                    HapticFeedback.selectionClick();
                    controller.togglePrayerNotification(prayer);
                  },
                ),
            const Divider(height: 1),
            _SettingRow(
              icon: Icons.music_note_outlined,
              title: 'Athan sound',
              value: settings.sound.label,
              onTap: onPickSound,
            ),
            if (!ready)
              _NotificationWarning(
                message: 'Notifications are blocked. Allow them to receive prayer reminders.',
                actionLabel: 'Allow',
                onAction: controller.requestNotificationPermission,
              ),
            if (ready && !controller.exactAlarmsAllowed)
              _NotificationWarning(
                message: 'Exact timing is off. Allow alarms so reminders arrive at the exact minute.',
                actionLabel: 'Allow',
                onAction: controller.requestExactAlarms,
              ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: controller.sendTestNotification,
                icon: const Icon(Icons.notifications_none_rounded, size: 18),
                label: const Text('Send test notification'),
                style: TextButton.styleFrom(foregroundColor: palette.label),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NotificationWarning extends StatelessWidget {
  const _NotificationWarning({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: palette.accentDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: palette.inkMuted,
                height: 1.35,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: palette.accentDark),
            child: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: palette.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 14, color: palette.ink),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: palette.inkMuted,
          ),
        ),
      ],
    );
  }
}
