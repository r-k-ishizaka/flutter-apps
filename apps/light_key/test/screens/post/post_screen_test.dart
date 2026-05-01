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
import 'package:light_key/screens/post/post_screen_state.dart';
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

  Widget buildTestApp({
    required ReactionPickerLauncher pickReaction,
    AuthDataSource? authDataSource,
    PostDataSource? postDataSource,
  }) {
    return ChangeNotifierProvider(
      create: (_) => PostProvider(
        authRepository: AuthRepository(authDataSource ?? _FakeAuthDataSource()),
        postRepository: PostRepository(postDataSource ?? _FakePostDataSource()),
      ),
      child: MaterialApp(home: PostScreen(pickReaction: pickReaction)),
    );
  }

  testWidgets('リアクションピッカーで選んだ絵文字をカーソル位置へ挿入できる', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => ':smile:'));

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
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    await tester.enterText(find.byType(TextField), 'abc');

    final textField = tester.widget<TextField>(find.byType(TextField));
    final controller = textField.controller!;

    await tester.tap(find.byKey(const ValueKey('post-emoji-picker-button')));
    await tester.pumpAndSettle();

    expect(controller.text, 'abc');
  });

  testWidgets('絵文字ボタンは本文下にあり投稿ボタンは AppBar に表示される', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    expect(
      find.byKey(const ValueKey('post-emoji-picker-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('post-visibility-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('post-federation-toggle-button')),
      findsOneWidget,
    );
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

  testWidgets('公開範囲ボタンから public/home/follower を選択できる', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    await tester.tap(find.byKey(const ValueKey('post-visibility-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('post-visibility-option-public')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('post-visibility-option-home')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('post-visibility-option-follower')),
      findsOneWidget,
    );
    expect(find.text('ダイレクト'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('post-visibility-option-follower')),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-visibility-button')),
        matching: find.byIcon(Icons.lock),
      ),
      findsOneWidget,
    );
  });

  testWidgets('選択した公開範囲を付けて投稿する', (tester) async {
    final postDataSource = _RecordingPostDataSource();

    await tester.pumpWidget(
      buildTestApp(
        pickReaction: (_) async => null,
        authDataSource: _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
        postDataSource: postDataSource,
      ),
    );

    await tester.enterText(find.byType(TextField), '投稿テスト');

    await tester.tap(find.byKey(const ValueKey('post-visibility-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('post-visibility-option-home')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('post-federation-toggle-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('post-submit-button')));
    await tester.pumpAndSettle();

    expect(postDataSource.lastText, '投稿テスト');
    expect(postDataSource.lastVisibility, PostVisibility.home);
    expect(postDataSource.lastIsFederated, isFalse);
  });

  testWidgets('連合トグルを押すとロケットアイコンが切り替わる', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    final context = tester.element(find.byType(PostScreen));
    final errorColor = Theme.of(context).colorScheme.error;

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-federation-toggle-button')),
        matching: find.byIcon(Icons.rocket_launch_outlined),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('post-federation-toggle-button')));
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-federation-toggle-button')),
        matching: find.byIcon(Icons.rocket_launch),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('post-federation-off-slash')), findsOneWidget);

    final offRocket = tester.widget<Icon>(
      find.descendant(
        of: find.byKey(const ValueKey('post-federation-toggle-button')),
        matching: find.byIcon(Icons.rocket_launch),
      ),
    );
    expect(offRocket.color, errorColor);
  });

  testWidgets('フォームと絵文字ボタンの下にタイムライン形式のプレビューを表示する', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

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
  _FakeAuthDataSource({this.session});

  final AuthSession? session;

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
  Future<AuthSession?> loadSession() async => session;

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<User> verify(String baseUrl, String accessToken) async =>
      const User(id: 'user-1', username: 'alice', name: 'Alice');
}

class _FakePostDataSource implements PostDataSource {
  @override
  Future<void> createPost(
    AuthSession session,
    String text,
    PostVisibility visibility,
    bool isFederated,
  ) async {}
}

class _RecordingPostDataSource implements PostDataSource {
  String? lastText;
  PostVisibility? lastVisibility;
  bool? lastIsFederated;

  @override
  Future<void> createPost(
    AuthSession session,
    String text,
    PostVisibility visibility,
    bool isFederated,
  ) async {
    lastText = text;
    lastVisibility = visibility;
    lastIsFederated = isFederated;
  }
}
