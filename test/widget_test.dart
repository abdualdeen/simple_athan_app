import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:athan_app/app.dart';

void main() {
  testWidgets('home screen shows dates, location and prayer times', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const AthanApp());
    await tester.pump();

    expect(find.text('Assalamu Alaikum'), findsOneWidget);
    expect(find.text('London, United Kingdom'), findsOneWidget);
    expect(find.text('Fajr'), findsOneWidget);
    expect(find.text('Dhuhr'), findsOneWidget);
    expect(find.text('Maghrib'), findsOneWidget);
    expect(find.text('Isha'), findsOneWidget);
    expect(find.text('NEXT PRAYER'), findsOneWidget);

    // Dispose the tree so the countdown timer is cancelled.
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hamburger menu opens the drawer', (WidgetTester tester) async {
    await tester.pumpWidget(const AthanApp());
    await tester.pump();

    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Qibla Direction'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });
}
