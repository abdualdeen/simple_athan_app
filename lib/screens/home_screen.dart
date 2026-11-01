import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_header.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_list.dart';
import 'manual_location_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.controller});

  final PrayerTimesController controller;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh the rolling notification window and pick up permission
      // changes made in the system settings.
      unawaited(widget.controller.syncNotifications());
    }
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SettingsScreen(controller: widget.controller),
      ),
    );
  }

  void _openManualLocation() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            ManualLocationScreen(controller: widget.controller),
      ),
    );
  }

  void _showLocationSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.cream,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) => _LocationSheet(
        controller: widget.controller,
        onEnterManually: () {
          Navigator.of(sheetContext).pop();
          _openManualLocation();
        },
        onOpenSettings: () {
          Navigator.of(sheetContext).pop();
          _openSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (BuildContext context, Widget? _) {
        final PrayerTimesController controller = widget.controller;
        if (controller.isInitializing) return const _StartupView();

        return Scaffold(
          key: _scaffoldKey,
          drawer: AppDrawer(controller: controller),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    HomeHeader(
                      date: controller.now,
                      locationName: controller.location.name,
                      isLocating: controller.isLocating,
                      onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                      onLocationTap: _showLocationSheet,
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: -76,
                      child: NextPrayerCard(
                        now: controller.now,
                        day: controller.day,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 96),
                if (controller.locationError != null)
                  _LocationNotice(
                    message: controller.locationError!,
                    locationName: controller.location.name,
                    onRetry: controller.refreshLocation,
                  ),
                PrayerList(
                  day: controller.day,
                  muted: controller.notifications.muted,
                  onToggleMute: controller.togglePrayerNotification,
                ),
                const SizedBox(height: 12),
                _CalculationNote(controller: controller, onTap: _openSettings),
                const SizedBox(height: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StartupView extends StatelessWidget {
  const _StartupView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.emeraldDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.nightlight_round,
                color: AppColors.goldSoft,
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Athan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.goldSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationNotice extends StatelessWidget {
  const _LocationNotice({
    required this.message,
    required this.locationName,
    required this.onRetry,
  });

  final String message;
  final String locationName;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.location_off_outlined,
              size: 18,
              color: AppColors.goldDark,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.ink,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Showing times for $locationName.',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: AppColors.goldDark),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculationNote extends StatelessWidget {
  const _CalculationNote({required this.controller, required this.onTap});

  final PrayerTimesController controller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: AppColors.emerald.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            const Icon(
              Icons.info_outline_rounded,
              size: 17,
              color: AppColors.emerald,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Calculated with ${controller.settings.method.label} • '
                '${controller.settings.madhab.label} Asr',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(foregroundColor: AppColors.emerald),
              child: const Text('Change'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationSheet extends StatelessWidget {
  const _LocationSheet({
    required this.controller,
    required this.onEnterManually,
    required this.onOpenSettings,
  });

  final PrayerTimesController controller;
  final VoidCallback onEnterManually;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListenableBuilder(
        listenable: controller,
        builder: (BuildContext context, Widget? _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.inkMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: <Widget>[
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
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
                  if (controller.locationError != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      controller.locationError!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFFB3261E),
                        height: 1.35,
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
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
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Icon(Icons.my_location_rounded, size: 18),
                      label: Text(
                        controller.isLocating
                            ? 'Locating…'
                            : 'Update from device',
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
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onEnterManually,
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                        size: 18,
                      ),
                      label: const Text('Enter location manually'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.emerald,
                        side: BorderSide(
                          color: AppColors.emerald.withValues(alpha: 0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: onOpenSettings,
                      icon: const Icon(Icons.tune_rounded, size: 18),
                      label: const Text('Calculation settings'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
