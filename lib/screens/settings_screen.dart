import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../models/notification_settings.dart';
import '../models/prayer.dart';
import '../models/prayer_settings.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final PrayerTimesController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.emerald,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? _) {
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
                          controller.updateSettings(
                            controller.settings.copyWith(
                              madhab: selection.first,
                            ),
                          );
                        },
                        style: SegmentedButton.styleFrom(
                          selectedBackgroundColor: AppColors.emerald,
                          selectedForegroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                          side: BorderSide(
                            color: AppColors.emerald.withValues(alpha: 0.2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.settings.madhab.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const _SectionLabel('NOTIFICATIONS'),
              _NotificationCard(controller: controller),
              const SizedBox(height: 24),
              const _SectionLabel('ABOUT'),
              const _SettingsCard(
                child: Column(
                  children: <Widget>[
                    _InfoRow(
                      icon: Icons.public_rounded,
                      title: 'High latitude rule',
                      value: 'Automatic',
                    ),
                    SizedBox(height: 12),
                    _InfoRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Calculation engine',
                      value: 'Adhan',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Prayer times are calculated astronomically for your location. '
                'Times can differ by a minute or two from your local mosque.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.inkMuted,
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
    final PrayerMethod? selected = await showModalBottomSheet<PrayerMethod>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
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
                    color: AppColors.inkMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Calculation method',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
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
                              color: AppColors.ink,
                            ),
                          ),
                          trailing: method == controller.settings.method
                              ? const Icon(
                                  Icons.check_circle_rounded,
                                  color: AppColors.emerald,
                                  size: 20,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetContext).pop(method),
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
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: AppColors.inkMuted,
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
    return Material(
      color: AppColors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.07)),
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
                  color: AppColors.cream,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.emerald,
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
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.location.coordinatesLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
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
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFFB3261E),
                height: 1.35,
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: controller.isLocating
                  ? null
                  : controller.refreshLocation,
              icon: controller.isLocating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.my_location_rounded, size: 18),
              label: Text(
                controller.isLocating ? 'Locating…' : 'Update from device',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.emerald,
                foregroundColor: Colors.white,
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.emerald),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.controller});

  final PrayerTimesController controller;

  @override
  Widget build(BuildContext context) {
    final NotificationSettings settings = controller.notifications;
    final bool ready = controller.notificationsReady;

    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            secondary: const Icon(
              Icons.notifications_active_outlined,
              color: AppColors.emerald,
            ),
            title: const Text(
              'Prayer reminders',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            subtitle: const Text(
              'Adhan notification at each prayer time',
              style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
            ),
            value: settings.enabled,
            onChanged: controller.setNotificationsEnabled,
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
                    color: AppColors.emerald,
                  ),
                  title: Text(
                    prayer.label,
                    style: const TextStyle(fontSize: 14, color: AppColors.ink),
                  ),
                  value: settings.isEnabledFor(prayer),
                  onChanged: (_) => controller.togglePrayerNotification(prayer),
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
                style: TextButton.styleFrom(foregroundColor: AppColors.emerald),
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
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.warning_amber_rounded,
            size: 18,
            color: AppColors.goldDark,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.inkMuted,
                height: 1.35,
              ),
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: AppColors.goldDark),
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
    return Row(
      children: <Widget>[
        Icon(icon, size: 20, color: AppColors.emerald),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 14, color: AppColors.ink),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.inkMuted,
          ),
        ),
      ],
    );
  }
}
