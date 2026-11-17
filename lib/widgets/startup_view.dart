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

import '../theme/app_theme.dart';

/// Full-screen loader shown while saved settings are being read.
class StartupView extends StatelessWidget {
  const StartupView({super.key});

  @override
  Widget build(BuildContext context) {
    final AppPalette palette = context.palette;
    return Scaffold(
      backgroundColor: palette.primaryDeep,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 72,
              height: 72,
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
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Athan',
              style: TextStyle(
                color: palette.onPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(palette.accentSoft),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
