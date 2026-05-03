import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/datasources/auth_data_source.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/response_with_cache_hints.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/screens/auth/auth_provider.dart';
import 'package:light_key/screens/home/home_screen.dart';
import 'package:provider/provider.dart';

void main() {
  group('HomeScreen app bar title', () {
    Widget buildSubject({
      required String currentPath,
      required int selectedIndex,
    }) {
      return ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(AuthRepository(_FakeAuthDataSource())),
        child: MaterialApp(
          home: HomeScreen(
            currentPath: currentPath,
            selectedIndex: selectedIndex,
            actions: const <Widget>[],
            onDestinationSelected: (_) {},
            onPostTap: () {},
            child: const SizedBox.shrink(),
          ),
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

class _FakeAuthDataSource implements AuthDataSource {
  @override
  Future<void> clearSession() async {}

  @override
  Future<String> getOAuthToken(
    String baseUrl,
    String clientId,
    String code,
    String redirectUri, {
    String? codeVerifier,
  }) async {
    return 'token';
  }

  @override
  Future<AuthSession?> loadSession() async {
    return null;
  }

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<ResponseWithCacheHints<User>> verify(
    String baseUrl,
    String accessToken,
  ) async {
    return const ResponseWithCacheHints(data: User());
  }
}
