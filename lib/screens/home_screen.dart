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
import '../models/app_location.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_header.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_list.dart';
import '../widgets/startup_view.dart';
import 'manual_location_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final PrayerTimesController controller;
  final ThemeController themeController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  /// Days between the shown prayer list and today; `0` shows today.
  int _dayOffset = 0;

  /// Local midnight [offset] days from [today]. Calendar-day arithmetic keeps
  /// the result at midnight across DST changes, unlike adding a [Duration].
  DateTime _dateForOffset(DateTime today, int offset) =>
      DateTime(today.year, today.month, today.day + offset);

  /// Opens a date picker and jumps to the chosen day.
  Future<void> _pickDate() async {
    final PrayerTimesController controller = widget.controller;
    final DateTime today = DateUtils.dateOnly(controller.now);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateForOffset(today, _dayOffset),
      firstDate: DateTime(today.year - 10, today.month, today.day),
      lastDate: DateTime(today.year + 10, today.month, today.day),
      helpText: 'Jump to a date',
    );
    if (picked == null) return;
    // Compare midnights in UTC so the difference is always whole days.
    final int offset = DateTime.utc(
      picked.year,
      picked.month,
      picked.day,
    ).difference(DateTime.utc(today.year, today.month, today.day)).inDays;
    if (!mounted) return;
    setState(() => _dayOffset = offset);
  }

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
        builder: (BuildContext context) => SettingsScreen(
          controller: widget.controller,
          themeController: widget.themeController,
        ),
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
      backgroundColor: context.palette.background,
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
        final DateTime selectedDate = _dateForOffset(
          controller.now,
          _dayOffset,
        );
        if (controller.isInitializing) return const StartupView();

        return Scaffold(
          key: _scaffoldKey,
          endDrawer: AppDrawer(
            controller: controller,
            themeController: widget.themeController,
          ),
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
                      onMenuTap: () =>
                          _scaffoldKey.currentState?.openEndDrawer(),
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
                  schedule: _dayOffset == 0
                      ? controller.day.schedule
                      : controller.scheduleForDate(selectedDate),
                  date: selectedDate,
                  dayOffset: _dayOffset,
                  nextId: _dayOffset == 0 ? controller.day.next.id : null,
                  muted: controller.notifications.muted,
                  onToggleMute: controller.togglePrayerNotification,
                  onPreviousDay: () => setState(() => _dayOffset -= 1),
                  onNextDay: () => setState(() => _dayOffset += 1),
                  onBackToToday: () => setState(() => _dayOffset = 0),
                  onPickDate: _pickDate,
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
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: palette.accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: palette.accent.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(
              Icons.location_off_outlined,
              size: 18,
              color: palette.accentDark,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: palette.ink,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Showing times for $locationName.',
                    style: TextStyle(fontSize: 11.5, color: palette.inkMuted),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(foregroundColor: palette.accentDark),
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
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        decoration: BoxDecoration(
          color: palette.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.info_outline_rounded, size: 17, color: palette.primary),
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
              style: TextButton.styleFrom(foregroundColor: palette.label),
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
    final AppPalette palette = context.palette;
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
                        color: palette.inkMuted.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: palette.ink,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (controller.savedLocations.isEmpty)
                    _SavedLocationRow(location: controller.location)
                  else
                    for (int i = 0; i < controller.savedLocations.length; i++)
                      _SavedLocationRow(
                        location: controller.savedLocations[i],
                        active: i == controller.activeLocationIndex,
                        onTap: () => controller.switchLocation(i),
                        onDelete:
                            controller.savedLocations.length > 1 &&
                                i != controller.activeLocationIndex
                            ? () => controller.removeLocation(i)
                            : null,
                      ),
                  if (controller.savedLocations.length == 1) ...<Widget>[
                    const SizedBox(height: 4),
                    _AddLocationRow(onTap: onEnterManually),
                  ],
                  if (controller.locationError != null) ...<Widget>[
                    const SizedBox(height: 12),
                    Text(
                      controller.locationError!,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: palette.error,
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
                        controller.isLocating
                            ? 'Locating…'
                            : 'Update from device',
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
                      onPressed: onEnterManually,
                      icon: const Icon(
                        Icons.edit_location_alt_outlined,
                        size: 18,
                      ),
                      label: const Text('Enter location manually'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: palette.label,
                        side: BorderSide(
                          color: palette.label.withValues(alpha: 0.35),
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
                        foregroundColor: palette.label,
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

/// A saved location the user can switch to. Without [onTap] it renders as a
/// plain row, used when no location has been resolved yet.
class _SavedLocationRow extends StatelessWidget {
  const _SavedLocationRow({
    required this.location,
    this.active = false,
    this.onTap,
    this.onDelete,
  });

  final AppLocation location;
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: palette.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: palette.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    location.fromDevice
                        ? Icons.my_location_rounded
                        : Icons.location_on_outlined,
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
                        location.name,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: palette.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location.coordinatesLabel,
                        style: TextStyle(fontSize: 12, color: palette.inkMuted),
                      ),
                    ],
                  ),
                ),
                if (active)
                  Icon(
                    Icons.check_circle_rounded,
                    color: palette.primary,
                    size: 20,
                  )
                else if (onDelete != null)
                  IconButton(
                    onPressed: onDelete,
                    tooltip: 'Remove location',
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: palette.inkMuted,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Invites the user to save a second location while a slot is free.
class _AddLocationRow extends StatelessWidget {
  const _AddLocationRow({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: palette.primary.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_circle_outline_rounded,
                size: 20,
                color: palette.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Add second location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: palette.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
