import 'dart:async';

import 'package:flutter/material.dart';

import '../data/prayer_times_service.dart';
import '../models/prayer.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/home_header.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ValueNotifier<DateTime> _now = ValueNotifier<DateTime>(DateTime.now());
  final Set<PrayerId> _muted = <PrayerId>{};
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _now.value = DateTime.now(),
    );
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _now.dispose();
    super.dispose();
  }

  void _toggleMute(PrayerId id) {
    setState(() {
      if (!_muted.add(id)) _muted.remove(id);
    });
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                HomeHeader(
                  date: _now.value,
                  locationName: PrayerTimesService.locationName,
                  onMenuTap: () => _scaffoldKey.currentState?.openDrawer(),
                  onLocationTap: () => _showComingSoon('Location picker'),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: -76,
                  child: ValueListenableBuilder<DateTime>(
                    valueListenable: _now,
                    builder: (BuildContext context, DateTime now, Widget? _) =>
                        NextPrayerCard(now: now),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 96),
            ValueListenableBuilder<DateTime>(
              valueListenable: _now,
              builder: (BuildContext context, DateTime now, Widget? _) =>
                  PrayerList(
                    now: now,
                    muted: _muted,
                    onToggleMute: _toggleMute,
                  ),
            ),
            const SizedBox(height: 12),
            const _CalculationNote(),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}

class _CalculationNote extends StatelessWidget {
  const _CalculationNote();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.emerald.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Icon(
              Icons.info_outline_rounded,
              size: 17,
              color: AppColors.emerald,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Times shown are sample data until location-based calculation '
                'is connected. Calculation methods will be configurable in '
                'Settings.',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
