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

import '../controllers/prayer_times_controller.dart';
import '../models/app_location.dart';
import '../theme/app_theme.dart';

/// Lets the user pick a location by place name or coordinates instead of
/// sharing the device's position.
class ManualLocationScreen extends StatefulWidget {
  const ManualLocationScreen({super.key, required this.controller});

  final PrayerTimesController controller;

  @override
  State<ManualLocationScreen> createState() => _ManualLocationScreenState();
}

class _ManualLocationScreenState extends State<ManualLocationScreen> {
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<AppLocation> _results = const <AppLocation>[];
  bool _isSearching = false;
  String? _error;
  int _requestId = 0;

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final String query = _queryController.text.trim();
    if (query.isEmpty) return;

    _focusNode.unfocus();
    final int requestId = ++_requestId;
    setState(() {
      _isSearching = true;
      _error = null;
      _results = const <AppLocation>[];
    });

    try {
      final List<AppLocation> results = await widget.controller.searchLocations(
        query,
      );
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isSearching = false;
        _results = results;
        if (results.isEmpty) {
          _error =
              'No places found for "$query". Try a city and country, or '
              'enter coordinates.';
        }
      });
    } catch (error) {
      if (!mounted || requestId != _requestId) return;
      setState(() {
        _isSearching = false;
        _error =
            'Could not search for that place. Check your connection and try '
            'again, or enter coordinates.';
      });
    }
  }

  Future<void> _select(AppLocation location) async {
    await widget.controller.setManualLocation(location);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _clear() {
    _queryController.clear();
    setState(() {
      _results = const <AppLocation>[];
      _error = null;
    });
  }

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
          'Enter location',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: <Widget>[
          TextField(
            controller: _queryController,
            focusNode: _focusNode,
            autofocus: true,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _search(),
            style: TextStyle(color: palette.ink),
            decoration: InputDecoration(
              hintText: 'City, country or coordinates',
              hintStyle: TextStyle(color: palette.inkMuted),
              prefixIcon: Icon(Icons.search_rounded, color: palette.inkMuted),
              suffixIcon: _queryController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _clear,
                      tooltip: 'Clear',
                      icon: Icon(Icons.close_rounded, color: palette.inkMuted),
                    ),
              filled: true,
              fillColor: palette.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: palette.primary.withValues(alpha: 0.12),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: palette.primary, width: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Examples: London, United Kingdom · 51.5074, -0.1278',
            style: TextStyle(fontSize: 12, color: palette.inkMuted),
          ),
          if (widget.controller.savedLocations.length == 1) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'A place you choose is saved as a second location you can switch '
              'to from the home screen.',
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
          ] else if (widget.controller.savedLocations.length >= 2) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              'Both saved locations are in use. A new place replaces '
              '${widget.controller.location.name}.',
              style: TextStyle(fontSize: 12, color: palette.inkMuted),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isSearching ? null : _search,
              icon: _isSearching
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
                  : const Icon(Icons.search_rounded, size: 18),
              label: Text(_isSearching ? 'Searching…' : 'Search'),
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
          if (_error != null) ...<Widget>[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: palette.accent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: palette.accentDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _error!,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: palette.ink,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_results.isNotEmpty) ...<Widget>[
            const SizedBox(height: 22),
            Text(
              'RESULTS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: palette.inkMuted,
              ),
            ),
            const SizedBox(height: 8),
            for (final AppLocation location in _results)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: palette.surface,
                  borderRadius: BorderRadius.circular(16),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: palette.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: palette.primary,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      location.name,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                        color: palette.ink,
                      ),
                    ),
                    subtitle: Text(
                      location.coordinatesLabel,
                      style: TextStyle(fontSize: 12, color: palette.inkMuted),
                    ),
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: palette.inkMuted,
                    ),
                    onTap: () => _select(location),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
