import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/screens/home/home_screen.dart';

void main() {
  group('HomeScreen app bar title', () {
    Widget buildSubject({required String currentPath, required int selectedIndex}) {
      return MaterialApp(
        home: HomeScreen(
          currentPath: currentPath,
          selectedIndex: selectedIndex,
          actions: const <Widget>[],
          onDestinationSelected: (_) {},
          onPostTap: () {},
          child: const SizedBox.shrink(),
        ),
      );
    }

    testWidgets('Timeline では ホーム を表示する', (tester) async {
      await tester.pumpWidget(
        buildSubject(currentPath: '/home/timeline', selectedIndex: 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('ホーム'), findsOneWidget);
      expect(find.text('通知'), findsNothing);
    });

    testWidgets('Notifications では 通知 を表示する', (tester) async {
      await tester.pumpWidget(
        buildSubject(currentPath: '/home/notifications', selectedIndex: 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('通知'), findsOneWidget);
      expect(find.text('ホーム'), findsNothing);
    });
  });
}
