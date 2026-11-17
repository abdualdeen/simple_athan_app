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

const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// e.g. `Saturday, 1 November 2026`.
String formatGregorianDate(DateTime date) =>
    '${_weekdays[date.weekday - 1]}, ${date.day} ${_months[date.month - 1]} ${date.year}';

/// e.g. `5:42 AM`.
String formatClockTime(DateTime time) {
  final int hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final String minute = time.minute.toString().padLeft(2, '0');
  final String period = time.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}

/// e.g. `01:24:05`, used for the live countdown.
String formatCountdown(Duration duration) {
  final int total = duration.inSeconds < 0 ? 0 : duration.inSeconds;
  final String hours = (total ~/ 3600).toString().padLeft(2, '0');
  final String minutes = ((total % 3600) ~/ 60).toString().padLeft(2, '0');
  final String seconds = (total % 60).toString().padLeft(2, '0');
  return '$hours:$minutes:$seconds';
}
