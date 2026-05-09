import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:light_key/datasources/auth_data_source.dart';
import 'package:light_key/datasources/post_data_source.dart';
import 'package:light_key/di/di.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/response_with_cache_hints.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/repositories/post_repository.dart';
import 'package:light_key/screens/auth/auth_provider.dart';
import 'package:light_key/screens/post/post_screen_param.dart';
import 'package:light_key/screens/post/post_provider.dart';
import 'package:light_key/screens/post/post_screen.dart';
import 'package:light_key/screens/post/post_screen_state.dart';
import 'package:light_key/services/emoji_cache.dart';
import 'package:light_key/widgets/emoji_text.dart';
import 'package:provider/provider.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    final emojiCache = EmojiCache()
      ..populate({
        'smile': const EmojiCacheEntry(url: 'https://example.com/smile.png'),
        'smirk': const EmojiCacheEntry(url: 'https://example.com/smirk.png'),
        'wave': const EmojiCacheEntry(url: 'https://example.com/wave.png'),
      });
    getIt.registerSingleton<EmojiCache>(emojiCache);
  });

  tearDown(() async {
    await getIt.reset();
  });

  Widget buildTestApp({
    required ReactionPickerLauncher pickReaction,
    AuthDataSource? authDataSource,
    PostDataSource? postDataSource,
    PostScreenParam param = const PostScreenParam.normal(),
  }) {
    final authRepository = AuthRepository(authDataSource ?? _FakeAuthDataSource());

    return MultiProvider(
      providers: [
        Provider<EmojiCache>.value(value: getIt<EmojiCache>()),
        ChangeNotifierProvider(create: (_) => AuthProvider(authRepository)),
        ChangeNotifierProvider(
          create: (_) => PostProvider(
            authRepository: authRepository,
            postRepository: PostRepository(
              postDataSource ?? _FakePostDataSource(),
            ),
          ),
        ),
      ],
      child: MaterialApp(
        home: PostScreen(
          pickReaction: pickReaction,
          param: param,
        ),
      ),
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
    expect(find.byKey(const ValueKey('post-cw-toggle-button')), findsOneWidget);
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
    expect(postDataSource.lastCw, isNull);
    expect(postDataSource.lastVisibility, PostVisibility.home);
    expect(postDataSource.lastIsFederated, isFalse);
    expect(postDataSource.lastReplyId, isNull);
  });

  testWidgets('返信コンテキストがある場合は簡易カードを表示して replyId を送信する', (tester) async {
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
        param: const PostScreenParam.reply(
          targetId: 'note-42',
          userName: 'alice',
          displayName: 'Alice',
          text: '返信元ノートです',
          avatarUrl: 'https://example.com/alice.png',
        ),
      ),
    );

    expect(find.byKey(const ValueKey('post-reply-target-card')), findsOneWidget);
    expect(find.text('返信先: @alice'), findsOneWidget);
    expect(find.text('返信元ノートです'), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-note-preview')),
        matching: find.text('Alice'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-note-preview')),
        matching: find.text('@alice'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('post-note-preview')),
        matching: find.text('返信元ノートです'),
      ),
      findsOneWidget,
    );
    final cachedImages = tester
        .widgetList<CachedNetworkImage>(find.byType(CachedNetworkImage))
        .toList();
    expect(
      cachedImages.where((image) => image.imageUrl == 'https://example.com/alice.png').length,
      1,
    );

    await tester.enterText(find.byType(TextField).first, 'リプライ本文');
    await tester.tap(find.byKey(const ValueKey('post-submit-button')));
    await tester.pumpAndSettle();

    expect(postDataSource.lastText, 'リプライ本文');
    expect(postDataSource.lastReplyId, 'note-42');
  });

  testWidgets('引用コンテキストがある場合は引用元ノートをEmojiTextで表示して renoteId を送信する', (tester) async {
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
        param: const PostScreenParam.quote(
          targetId: 'note-99',
          userName: 'alice',
          displayName: 'Alice',
          text: '引用元 :smile: ノート',
          avatarUrl: 'https://example.com/alice.png',
        ),
      ),
    );

    expect(find.byKey(const ValueKey('post-renote-target-card')), findsOneWidget);

    final renoteText = tester.widget<EmojiText>(
      find.byKey(const ValueKey('post-renote-target-text')),
    );
    expect(renoteText.text, '引用元 :smile: ノート');

    await tester.enterText(find.byType(TextField).first, '引用リノート本文');
    await tester.tap(find.byKey(const ValueKey('post-submit-button')));
    await tester.pumpAndSettle();

    expect(postDataSource.lastText, '引用リノート本文');
    expect(postDataSource.lastRenoteId, 'note-99');
  });

  testWidgets('CWトグルでCW入力欄を表示し本文欄は維持される', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    expect(find.byKey(const ValueKey('post-cw-text-field')), findsNothing);
    expect(find.byKey(const ValueKey('post-body-text-field')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('post-cw-toggle-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('post-cw-text-field')), findsOneWidget);
    expect(find.byKey(const ValueKey('post-body-text-field')), findsOneWidget);
  });

  testWidgets('CWモード投稿ではCWと本文を送信する', (tester) async {
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

    await tester.tap(find.byKey(const ValueKey('post-cw-toggle-button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('post-cw-text-field')),
      'ネタバレあり',
    );
    await tester.enterText(
      find.byKey(const ValueKey('post-body-text-field')),
      '本文です',
    );

    await tester.tap(find.byKey(const ValueKey('post-submit-button')));
    await tester.pumpAndSettle();

    expect(postDataSource.lastCw, 'ネタバレあり');
    expect(postDataSource.lastText, '本文です');
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

  testWidgets(':入力で絵文字サジェストを表示し選択でショートコードに置換する', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    await tester.enterText(find.byType(TextField), ':sm');
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('post-emoji-suggestion-menu')), findsOneWidget);
    expect(find.byKey(const ValueKey('post-emoji-suggestion-item-smile')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('post-emoji-suggestion-item-smile')));
    await tester.pumpAndSettle();

    final textField = tester.widget<TextField>(find.byType(TextField));
    final controller = textField.controller!;
    expect(controller.text, ':smile:');
    expect(controller.selection, const TextSelection.collapsed(offset: 7));
  });

  testWidgets('範囲選択中は絵文字サジェストを表示しない', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    await tester.enterText(find.byType(TextField), ':smile');

    final textField = tester.widget<TextField>(find.byType(TextField));
    final controller = textField.controller!;
    controller.value = controller.value.copyWith(
      selection: const TextSelection(baseOffset: 0, extentOffset: 3),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('post-emoji-suggestion-menu')), findsNothing);
  });

  testWidgets('IME変換中(composing)でも絵文字サジェストを表示する', (tester) async {
    await tester.pumpWidget(buildTestApp(pickReaction: (_) async => null));

    final textField = tester.widget<TextField>(find.byType(TextField));
    final controller = textField.controller!;
    controller.value = const TextEditingValue(
      text: ':sm',
      selection: TextSelection.collapsed(offset: 3),
      composing: TextRange(start: 1, end: 3),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byKey(const ValueKey('post-emoji-suggestion-menu')), findsOneWidget);
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
  Future<ResponseWithCacheHints<User>> verify(
    String baseUrl,
    String accessToken,
  ) async =>
      const ResponseWithCacheHints(
        data: User(id: 'user-1', username: 'alice', name: 'Alice'),
      );
}

class _FakePostDataSource implements PostDataSource {
  @override
  Future<ResponseWithCacheHints<Map<String, dynamic>>> createPost(
    AuthSession session,
    String text,
    String? cw,
    PostVisibility visibility,
    bool isFederated, {
    String? replyId,
    String? renoteId,
  }) async => const ResponseWithCacheHints(data: <String, dynamic>{});
}

class _RecordingPostDataSource implements PostDataSource {
  String? lastText;
  String? lastCw;
  String? lastReplyId;
  String? lastRenoteId;
  PostVisibility? lastVisibility;
  bool? lastIsFederated;

  @override
  Future<ResponseWithCacheHints<Map<String, dynamic>>> createPost(
    AuthSession session,
    String text,
    String? cw,
    PostVisibility visibility,
    bool isFederated, {
    String? replyId,
    String? renoteId,
  }) async {
    lastText = text;
    lastCw = cw;
    lastReplyId = replyId;
    lastRenoteId = renoteId;
    lastVisibility = visibility;
    lastIsFederated = isFederated;
    return const ResponseWithCacheHints(data: <String, dynamic>{});
  }
}
