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
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../utils/app_info.dart';

/// About screen with app metadata, the project link and licensing details.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

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
          'About',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: <Widget>[
          _AboutHeader(palette: palette),
          const SizedBox(height: 24),
          const _SectionLabel('APP'),
          _Card(
            palette: palette,
            child: Column(
              children: <Widget>[
                const _InfoRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Developer',
                  value: AppInfo.developer,
                ),
                const SizedBox(height: 12),
                _VersionRow(palette: palette),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('LINKS'),
          _Card(
            palette: palette,
            child: Column(
              children: <Widget>[
                _LinkRow(
                  palette: palette,
                  icon: Icons.code_rounded,
                  title: 'GitHub repository',
                  subtitle: AppInfo.githubUrl,
                  onTap: () => _openUrl(context, AppInfo.githubUrl),
                ),
                const SizedBox(height: 12),
                _LinkRow(
                  palette: palette,
                  icon: Icons.gavel_rounded,
                  title: AppInfo.licenseName,
                  subtitle: 'Read the full license text',
                  onTap: () => _openUrl(context, AppInfo.licenseUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('LICENSE'),
          _Card(
            palette: palette,
            child: Text(
              'Simply Athan is free software: you can redistribute it and/or '
              'modify it under the terms of the GNU General Public License as '
              'published by the Free Software Foundation, either version 3 of '
              'the License, or (at your option) any later version.\n\n'
              'This program is distributed in the hope that it will be useful, '
              'but WITHOUT ANY WARRANTY; without even the implied warranty of '
              'MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the '
              'GNU General Public License for more details.',
              style: TextStyle(
                fontSize: 13,
                height: 1.55,
                color: palette.inkMuted,
              ),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionLabel('OPEN SOURCE'),
          _Card(
            palette: palette,
            child: Column(
              children: <Widget>[
                const _PackageRow(
                  name: 'adhan_dart',
                  role: 'Prayer time calculation',
                ),
                const _PackageRow(
                  name: 'geolocator',
                  role: 'Location & position',
                ),
                const _PackageRow(name: 'geocoding', role: 'Place name lookup'),
                const _PackageRow(
                  name: 'shared_preferences',
                  role: 'Settings storage',
                ),
                const _PackageRow(
                  name: 'flutter_local_notifications',
                  role: 'Athan notifications',
                ),
                const _PackageRow(
                  name: 'flutter_timezone',
                  role: 'Device time zone',
                ),
                const _PackageRow(name: 'timezone', role: 'Time zone database'),
                const _PackageRow(name: 'compassx', role: 'Qibla compass'),
                const SizedBox(height: 8),
                _LinkRow(
                  palette: palette,
                  icon: Icons.description_outlined,
                  title: 'Licenses',
                  subtitle: 'Full license texts of every package',
                  onTap: () => _showLicenses(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final Uri uri = Uri.parse(url);
    final bool opened = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not open $url')));
    }
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: AppInfo.appName,
      applicationLegalese: 'Licensed under the ${AppInfo.licenseName}.',
    );
  }
}

class _AboutHeader extends StatelessWidget {
  const _AboutHeader({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[palette.primarySoft, palette.primaryDeep],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: palette.accent.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: palette.accent.withValues(alpha: 0.5)),
            ),
            child: Icon(
              Icons.mosque_rounded,
              color: palette.accentSoft,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppInfo.appName,
            style: TextStyle(
              color: palette.onPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppInfo.tagline,
            style: TextStyle(
              color: palette.onPrimary.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
          FutureBuilder<String>(
            future: AppInfo.version(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              final String version = snapshot.data ?? '…';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: palette.onPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Version $version',
                  style: TextStyle(
                    color: palette.onPrimary.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _VersionRow extends StatelessWidget {
  const _VersionRow({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: AppInfo.version(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        return _InfoRow(
          icon: Icons.tag_rounded,
          title: 'Version',
          value: snapshot.data ?? '—',
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: palette.label,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, required this.palette});

  final Widget child;
  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: palette.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: palette.primary.withValues(alpha: 0.08)),
      ),
      child: child,
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
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: palette.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: palette.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(fontSize: 14.5, color: palette.ink),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: palette.inkMuted,
          ),
        ),
      ],
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final AppPalette palette;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: <Widget>[
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: palette.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: palette.primary),
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: palette.inkMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.open_in_new_rounded, size: 18, color: palette.inkMuted),
          ],
        ),
      ),
    );
  }
}

class _PackageRow extends StatelessWidget {
  const _PackageRow({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            name,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: palette.ink,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 12),
          Text(
            role,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 12.5, color: palette.inkMuted),
          ),
        ],
      ),
    );
  }
}
