import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/datasources/auth_data_source.dart';
import 'package:light_key/datasources/post_data_source.dart';
import 'package:light_key/di/di.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/repositories/post_repository.dart';
import 'package:light_key/screens/post/post_provider.dart';
import 'package:light_key/screens/post/post_screen.dart';
import 'package:light_key/services/emoji_cache.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<EmojiCache>(EmojiCache());
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestApp({required ReactionPickerLauncher pickReaction}) {
    return ChangeNotifierProvider(
      create: (_) => PostProvider(
        authRepository: AuthRepository(_FakeAuthDataSource()),
        postRepository: PostRepository(_FakePostDataSource()),
      ),
      child: MaterialApp(home: PostScreen(pickReaction: pickReaction)),
    );
  }

  testWidgets('リアクションピッカーで選んだ絵文字をカーソル位置へ挿入できる', (tester) async {
    await tester.pumpWidget(
      buildTestApp(pickReaction: (_) async => ':smile:'),
    );

    await tester.enterText(find.byType(TextField), 'abc');

    final textField = tester.widget<TextField>(find.byType(TextField));
    final controller = textField.controller!;
    controller.value = controller.value.copyWith(
      selection: const TextSelection.collapsed(offset: 1),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('post-emoji-picker-button')));
    await tester.pumpAndSettle();

    expect(controller.text, 'a:smile:bc');
    expect(controller.selection, const TextSelection.collapsed(offset: 8));
  });

  testWidgets('リアクションピッカーを閉じた場合は入力内容を変更しない', (tester) async {
    await tester.pumpWidget(
      buildTestApp(pickReaction: (_) async => null),
    );

    await tester.enterText(find.byType(TextField), 'abc');

    final textField = tester.widget<TextField>(find.byType(TextField));
    final controller = textField.controller!;

    await tester.tap(find.byKey(const ValueKey('post-emoji-picker-button')));
    await tester.pumpAndSettle();

    expect(controller.text, 'abc');
  });

  testWidgets('絵文字ボタンは本文下にあり投稿ボタンは AppBar に表示される', (tester) async {
    await tester.pumpWidget(
      buildTestApp(pickReaction: (_) async => null),
    );

    expect(find.byKey(const ValueKey('post-emoji-picker-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('post-submit-button')), findsOneWidget);

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.appBar, isA<AppBar>());

    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.actions, isNotNull);
    expect(
      appBar.actions!.whereType<TextButton>().length,
      greaterThanOrEqualTo(1),
    );
  });

  testWidgets('フォームと絵文字ボタンの下にタイムライン形式のプレビューを表示する', (tester) async {
    await tester.pumpWidget(
      buildTestApp(pickReaction: (_) async => null),
    );

    expect(find.byKey(const ValueKey('post-note-preview')), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'プレビュー本文');
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-note-preview')),
        matching: find.text('プレビュー本文'),
      ),
      findsOneWidget,
    );
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
  }) async => 'token';

  @override
  Future<AuthSession?> loadSession() async => null;

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<User> verify(String baseUrl, String accessToken) async =>
      const User(id: 'user-1', username: 'alice', name: 'Alice');
}

class _FakePostDataSource implements PostDataSource {
  @override
  Future<void> createPost(AuthSession session, String text) async {}
}
