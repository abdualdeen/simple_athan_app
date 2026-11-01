import 'package:flutter/material.dart';

import '../controllers/prayer_times_controller.dart';
import '../controllers/theme_controller.dart';
import '../screens/settings_screen.dart';
import '../theme/app_theme.dart';

/// Side menu with the app's main destinations.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.controller,
    required this.themeController,
  });

  final PrayerTimesController controller;
  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Drawer(
      backgroundColor: palette.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: Column(
        children: <Widget>[
          const _DrawerHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              children: <Widget>[
                _DrawerItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: true,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  comingSoon: false,
                  onTap: () => _openSettings(context),
                ),
                _DrawerItem(
                  icon: Icons.explore_outlined,
                  label: 'Qibla Direction',
                  onTap: () => _showComingSoon(context, 'Qibla direction'),
                ),
                _DrawerItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notifications',
                  onTap: () => _showComingSoon(context, 'Notifications'),
                ),
                _DrawerItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About',
                  onTap: () => _showComingSoon(context, 'About'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Text(
              'Athan • v1.0.0',
              style: TextStyle(
                fontSize: 11,
                color: palette.inkMuted,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    final NavigatorState navigator = Navigator.of(context);
    navigator.pop();
    navigator.push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => SettingsScreen(
          controller: controller,
          themeController: themeController,
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text('$feature is coming soon.')));
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[palette.primarySoft, palette.primaryDeep],
        ),
        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: palette.accent.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: palette.accent.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  Icons.nightlight_round,
                  color: palette.accentSoft,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Athan',
                style: TextStyle(
                  color: palette.onPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Prayer times & Qibla',
                style: TextStyle(
                  color: palette.onPrimary.withValues(alpha: 0.7),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.comingSoon = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool comingSoon;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected
            ? palette.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 21,
                  color: selected ? palette.primary : palette.inkMuted,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? palette.primary : palette.ink,
                    ),
                  ),
                ),
                if (comingSoon && !selected)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: palette.accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      'Soon',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: palette.accentDark,
                      ),
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
