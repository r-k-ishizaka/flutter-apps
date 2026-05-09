import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/datasources/auth_data_source.dart';
import 'package:light_key/datasources/timeline_connection.dart';
import 'package:light_key/datasources/timeline_data_source.dart';
import 'package:light_key/di/di.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/note.dart';
import 'package:light_key/models/response_with_cache_hints.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/repositories/timeline_repository.dart';
import 'package:light_key/screens/timeline/timeline_provider.dart';
import 'package:light_key/screens/timeline/timeline_screen_state.dart';
import 'package:light_key/services/emoji_cache.dart';
import 'package:light_key/widgets/emoji_text.dart';
import 'package:light_key/widgets/note_actions/note_actions.dart';
import 'package:light_key/widgets/note_reaction_list.dart';
import 'package:light_key/widgets/timeline_list.dart';

void main() {
  setUp(() async {
    await getIt.reset();
    getIt.registerSingleton<EmojiCache>(EmojiCache());
  });

  group('TimelineProvider.fetch', () {
    test('既存ノートありの pull-to-refresh では isRefreshing を使う', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [_note(id: 'note-1', text: 'before')],
          () => Completer<List<Note>>().future,
        ],
      );
      final timelineRepository = TimelineRepository(timelineDataSource);
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: timelineRepository,
      );

      await provider.fetch();
      expect(provider.state, isA<TimelineScreenStateLoaded>());
      var loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.notes.map((note) => note.id), ['note-1']);

      final refreshCompleter = Completer<List<Note>>();
      timelineDataSource.fetchHandlers[1] = () => refreshCompleter.future;

      final refreshFuture = provider.fetch(showLoading: false);
      await Future<void>.delayed(Duration.zero);

      expect(provider.state, isA<TimelineScreenStateLoaded>());
      loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.isRefreshing, isTrue);
      expect(loadedState.notes.map((note) => note.id), ['note-1']);

      refreshCompleter.complete([
        _note(id: 'note-2', text: 'after'),
        _note(id: 'note-1', text: 'before'),
      ]);
      await refreshFuture;

      expect(provider.state, isA<TimelineScreenStateLoaded>());
      loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.isRefreshing, isFalse);
      expect(loadedState.message, isNull);
      expect(loadedState.notes.map((note) => note.id), ['note-2', 'note-1']);
    });

    test('refresh でサーバー応答に myReaction がなくても保持する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [_note(id: 'note-1').copyWith(myReaction: '👍')],
          () async => [_note(id: 'note-1')],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();
      var loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.notes.single.myReaction, '👍');

      await provider.fetch(showLoading: false);

      loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.notes.single.myReaction, '👍');
    });
  });

  group('TimelineProvider.createReaction', () {
    test('loaded 状態ではローカルの myReaction も更新する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [_note(id: 'note-1')],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();

      final message = await provider.createReaction(_note(id: 'note-1'), '👍');

      expect(message, isNull);
      expect(provider.state, isA<TimelineScreenStateLoaded>());
      final loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.notes.single.myReaction, '👍');
    });

    test('通常ノートにリアクションを送信する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [_note(id: 'note-1')],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final message = await provider.createReaction(_note(id: 'note-1'), '👍');

      expect(message, isNull);
      expect(timelineDataSource.reactionCalls, [('note-1', '👍')]);
    });

    test('既存リアクションがあるノートで別リアクションに切り替わる', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [
            _note(
              id: 'note-1',
            ).copyWith(reactions: const {':old:': 3}, myReaction: ':old:'),
          ],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();

      final message = await provider.createReaction(
        _note(id: 'note-1'),
        ':new:',
      );

      expect(message, isNull);
      final loadedState = provider.state as TimelineScreenStateLoaded;
      // WS 非接続時はカウントも楽観的に更新する。
      expect(loadedState.notes.single.myReaction, ':new:');
      expect(loadedState.notes.single.reactions[':old:'], 2);
      expect(loadedState.notes.single.reactions[':new:'], 1);
      expect(timelineDataSource.reactionCalls, [('note-1', ':new:')]);
    });

    test('本文絵文字の :name: はそのまま送信する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [
            _note(id: 'note-1').copyWith(
              reactions: const {':blob_bongo_cat_keyboard@.:': 1},
              myReaction: ':blob_bongo_cat_keyboard@.:',
            ),
          ],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();

      final message = await provider.createReaction(
        _note(id: 'note-1'),
        ':blob_bongo_cat_keyboard:',
      );

      expect(message, isNull);
      expect(timelineDataSource.reactionCalls, [
        ('note-1', ':blob_bongo_cat_keyboard:'),
      ]);
    });

    test('互換入力の :name@.: は :name: に変換して送信する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [
            _note(id: 'note-1').copyWith(
              reactions: const {':blob_uooo@.:': 3},
              myReaction: ':blob_uooo@.:',
            ),
          ],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();

      final message = await provider.createReaction(
        _note(id: 'note-1'),
        ':blob_bongo_cat_keyboard@.:',
      );

      expect(message, isNull);
      expect(timelineDataSource.reactionCalls, [
        ('note-1', ':blob_bongo_cat_keyboard:'),
      ]);
    });

    test('refreshで古いmyReactionが来てもreactionsと不整合なら現在値を優先する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [
          () async => [
            _note(
              id: 'note-1',
            ).copyWith(reactions: const {':old@.:': 3}, myReaction: ':old@.:'),
          ],
          () async => [
            _note(
              id: 'note-1',
            ).copyWith(reactions: const {':new@.:': 1}, myReaction: ':old@.:'),
          ],
        ],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      await provider.fetch();
      await provider.createReaction(_note(id: 'note-1'), ':new@.:');
      await provider.fetch(showLoading: false);

      final loadedState = provider.state as TimelineScreenStateLoaded;
      expect(loadedState.notes.single.myReaction, ':new:');
    });

    test('純粋リノートでは元ノートにリアクションを送信する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [() async => []],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final pureRenote = Note(
        id: 'renote-wrapper',
        text: '',
        createdAt: DateTime(2026, 4, 28, 12),
        user: const User(id: 'user-2', username: 'bob', name: 'Bob'),
        renote: _note(id: 'renoted-note'),
      );

      final message = await provider.createReaction(pureRenote, ':custom:');

      expect(message, isNull);
      expect(timelineDataSource.reactionCalls, [('renoted-note', ':custom:')]);
    });

    test('未認証時はエラーメッセージを返す', () async {
      final authRepository = AuthRepository(_FakeAuthDataSource());
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [() async => []],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final message = await provider.createReaction(_note(id: 'note-1'), '👍');

      expect(message, '先に認証してください。');
      expect(timelineDataSource.reactionCalls, isEmpty);
    });
  });

  group('TimelineProvider.createRenote', () {
    test('通常ノートをリノート送信する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [() async => []],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final message = await provider.createRenote(_note(id: 'note-1'));

      expect(message, isNull);
      expect(timelineDataSource.renoteCalls, ['note-1']);
    });

    test('純粋リノートでは元ノートにリノート送信する', () async {
      final authRepository = AuthRepository(
        _FakeAuthDataSource(
          session: const AuthSession(
            baseUrl: 'https://example.com',
            accessToken: 'token',
          ),
        ),
      );
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [() async => []],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final pureRenote = Note(
        id: 'renote-wrapper',
        text: '',
        createdAt: DateTime(2026, 4, 28, 12),
        user: const User(id: 'user-2', username: 'bob', name: 'Bob'),
        renote: _note(id: 'renoted-note'),
      );

      final message = await provider.createRenote(pureRenote);

      expect(message, isNull);
      expect(timelineDataSource.renoteCalls, ['renoted-note']);
    });

    test('未認証時はエラーメッセージを返す', () async {
      final authRepository = AuthRepository(_FakeAuthDataSource());
      final timelineDataSource = _FakeTimelineDataSource(
        fetchHandlers: [() async => []],
      );
      final provider = TimelineProvider(
        authRepository: authRepository,
        timelineRepository: TimelineRepository(timelineDataSource),
      );

      final message = await provider.createRenote(_note(id: 'note-1'));

      expect(message, '先に認証してください。');
      expect(timelineDataSource.renoteCalls, isEmpty);
    });
  });

  group('TimelineList refresh feedback', () {
    testWidgets('本文絵文字をタップするとノートと絵文字が渡される', (tester) async {
      final mockActions = _MockNoteActions();

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [_note(id: 'note-1', text: 'hello :custom:')],
            emojis: getIt<EmojiCache>().entries,
            actions: mockActions,
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('${EmojiText.emojiTapKeyPrefix}:custom:')),
      );
      await tester.pump();

      expect(mockActions.lastTappedNote?.id, 'note-1');
      expect(mockActions.lastTappedEmoji, ':custom:');
    });

    testWidgets('表示中のリアクションをタップすると送信コールバックが呼ばれる', (tester) async {
      final mockActions = _MockNoteActions();
      final noteWithReaction = _note(
        id: 'note-1',
      ).copyWith(reactions: const {'👍': 2});

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [noteWithReaction],
            emojis: getIt<EmojiCache>().entries,
            actions: mockActions,
          ),
        ),
      );

      await tester.tap(find.byKey(const ValueKey('reaction-chip-👍')));
      await tester.pump();

      expect(mockActions.lastTappedNote?.id, 'note-1');
      expect(mockActions.lastTappedReaction, '👍');
    });

    testWidgets('ノート本体タップでコールバックが呼ばれる', (tester) async {
      final mockActions = _MockNoteActions();

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [_note(id: 'note-1', text: 'note body')],
            emojis: getIt<EmojiCache>().entries,
            actions: mockActions,
          ),
        ),
      );

      await tester.tap(find.text('note body'));
      await tester.pump();

      expect(mockActions.lastTappedNote?.id, 'note-1');
    });

    testWidgets('他サーバー絵文字のリアクションチップはタップできない', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteReactionList(
              reactions: const {':custom@example.com:': 1},
              emojis: getIt<EmojiCache>().entries,
              onReactionTap: (_) => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(
        find.byKey(const ValueKey('reaction-chip-:custom@example.com:')),
      );
      await tester.pump();

      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byKey(
                const ValueKey('reaction-chip-:custom@example.com:'),
              ),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(tapped, isFalse);
      expect(decoration.color, isNull);
    });

    testWidgets('他サーバー絵文字がキャッシュ未ヒットなら取得エラー画像を表示する', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteReactionList(
              reactions: const {':aaa@test:': 1},
              emojis: getIt<EmojiCache>().entries,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      expect(find.text(':aaa@test:'), findsNothing);
    });

    testWidgets('純粋リノート更新時も renote.myReaction を保持する', (tester) async {
      const reactionKey = ':custom@.:';
      final theme = ThemeData(useMaterial3: true);

      Note pureRenoteWithReaction(String? myReaction) {
        return Note(
          id: 'wrapper-1',
          text: '',
          createdAt: DateTime(2026, 4, 28, 12),
          user: const User(id: 'user-2', username: 'bob', name: 'Bob'),
          renote: _note(
            id: 'note-1',
          ).copyWith(reactions: const {reactionKey: 1}, myReaction: myReaction),
        );
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TimelineList(
            notes: [pureRenoteWithReaction(':custom:')],
            emojis: getIt<EmojiCache>().entries,
          ),
        ),
      );
      await tester.pump();

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: TimelineList(
            notes: [pureRenoteWithReaction(null)],
            emojis: getIt<EmojiCache>().entries,
          ),
        ),
      );
      await tester.pump();

      // NoteReactionList は `:custom@.:` を `:custom:` に正規化してチップキーを生成する
      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('reaction-chip-:custom:')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, theme.colorScheme.primaryContainer);
      expect(decoration.border, isNotNull);
    });

    testWidgets('同一サーバー絵文字は正規化して myReaction と比較する', (tester) async {
      final theme = ThemeData(useMaterial3: true);

      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(
              child: NoteReactionList(
                reactions: const {':custom@.:': 1},
                emojis: getIt<EmojiCache>().entries,
                myReaction: ':custom:',
              ),
            ),
          ),
        ),
      );

      // NoteReactionList は `:custom@.:` を `:custom:` に正規化してチップキーを生成する
      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byKey(const ValueKey('reaction-chip-:custom:')),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = decoratedBox.decoration as BoxDecoration;

      expect(decoration.color, theme.colorScheme.primaryContainer);
      expect(decoration.border, isNotNull);
    });

    testWidgets('onRefresh開始直後に半透明になる', (tester) async {
      final completer = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [_note(id: 'note-1')],
            emojis: getIt<EmojiCache>().entries,
            onRefresh: () => completer.future,
          ),
        ),
      );

      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      final refreshFuture = refreshIndicator.onRefresh();
      await tester.pump();

      final loadingOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(loadingOpacity.opacity, 0.4);

      completer.complete();
      await refreshFuture;
      await tester.pump();

      final normalOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(normalOpacity.opacity, 1.0);
    });

    testWidgets('更新中はリストを半透明で表示する', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [_note(id: 'note-1')],
            emojis: getIt<EmojiCache>().entries,
            isRefreshing: true,
            onRefresh: () async {},
          ),
        ),
      );

      final opacityWidget = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(opacityWidget.opacity, 0.4);
      expect(opacityWidget.duration, Duration.zero);

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [_note(id: 'note-1')],
            emojis: getIt<EmojiCache>().entries,
            onRefresh: () async {},
          ),
        ),
      );

      final normalOpacityWidget = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(normalOpacityWidget.opacity, 1.0);
      expect(normalOpacityWidget.duration, const Duration(milliseconds: 220));

      expect(find.text('更新中...'), findsNothing);
      expect(find.text('最新の状態を確認しました'), findsNothing);
    });

    testWidgets('既存ノートありのメッセージ時も更新バナーは表示しない', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [_note(id: 'note-1')],
            emojis: getIt<EmojiCache>().entries,
            message: '更新に失敗しました',
            onRefresh: () async {},
          ),
        ),
      );

      expect(find.text('更新中...'), findsNothing);
      expect(find.text('最新の状態を確認しました'), findsNothing);
    });

    testWidgets('リアクションが17件以上ある場合は上位16件と「もっと見る」を表示する', (tester) async {
      final reactions = <String, int>{
        for (var i = 0; i < 18; i++) ':e$i:': 100 - i,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteReactionList(
              reactions: reactions,
              emojis: getIt<EmojiCache>().entries,
            ),
          ),
        ),
      );

      for (var i = 0; i < 16; i++) {
        expect(find.byKey(ValueKey('reaction-chip-:e$i:')), findsOneWidget);
      }
      expect(find.byKey(const ValueKey('reaction-chip-:e16:')), findsNothing);
      expect(find.byKey(const ValueKey('reaction-chip-:e17:')), findsNothing);
      expect(find.text('もっと見る'), findsOneWidget);
    });

    testWidgets('myReaction が17件目以降でもチップ表示される', (tester) async {
      final reactions = <String, int>{
        for (var i = 0; i < 18; i++) ':e$i:': 100 - i,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NoteReactionList(
              reactions: reactions,
              emojis: getIt<EmojiCache>().entries,
              myReaction: ':e16:',
            ),
          ),
        ),
      );

      // 上位16件に加えて、自分のリアクション(:e16:)が追加表示される
      expect(find.byKey(const ValueKey('reaction-chip-:e16:')), findsOneWidget);
      expect(find.byKey(const ValueKey('reaction-chip-:e17:')), findsNothing);
      expect(find.text('もっと見る'), findsOneWidget);
    });

    testWidgets('引用ノート部分をタップすると引用元ノートが渡される', (tester) async {
      final mockActions = _MockNoteActions();
      final quoted = _note(id: 'quoted-1', text: 'quoted body');
      final quoteRenote = _note(id: 'quote-1', text: 'outer body').copyWith(
        renote: quoted,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TimelineList(
            notes: [quoteRenote],
            emojis: getIt<EmojiCache>().entries,
            actions: mockActions,
          ),
        ),
      );

      await tester.tap(find.text('quoted body'));
      await tester.pump();

      expect(mockActions.lastTappedNote?.id, 'quoted-1');
    });
  });
}

Note _note({required String id, String text = 'hello'}) {
  return Note(
    id: id,
    text: text,
    createdAt: DateTime(2026, 4, 28, 12),
    user: const User(
      id: 'user-1',
      username: 'sample_user',
      name: 'Sample User',
    ),
  );
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
  }) async => throw UnimplementedError();

  @override
  Future<AuthSession?> loadSession() async => session;

  @override
  Future<void> saveSession(AuthSession session) async {}

  @override
  Future<ResponseWithCacheHints<User>> verify(
    String baseUrl,
    String accessToken,
  ) async => const ResponseWithCacheHints(
    data: User(id: 'user-1', username: 'sample_user', name: 'Sample User'),
  );
}

class _FakeTimelineDataSource implements TimelineDataSource {
  _FakeTimelineDataSource({required this.fetchHandlers});

  final List<Future<List<Note>> Function()> fetchHandlers;
  final List<(String noteId, String reaction)> reactionCalls = [];
  final List<String> renoteCalls = [];
  var _fetchIndex = 0;

  @override
  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  }) async {
    reactionCalls.add((noteId, reaction));
  }

  @override
  Future<void> createRenote(
    AuthSession session, {
    required String noteId,
  }) async {
    renoteCalls.add(noteId);
  }

  @override
  Future<ResponseWithCacheHints<Note>> fetchNote(
    AuthSession session,
    String noteId,
  ) async => ResponseWithCacheHints(data: _note(id: noteId));

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async {
    final index = _fetchIndex < fetchHandlers.length
        ? _fetchIndex
        : fetchHandlers.length - 1;
    _fetchIndex += 1;
    final notes = await fetchHandlers[index]();
    return ResponseWithCacheHints(data: notes);
  }

  @override
  TimelineConnection openConnection(AuthSession session) =>
      _FakeTimelineConnection();
}

class _FakeTimelineConnection implements TimelineConnection {
  @override
  Future<void> close() async {}

  @override
  void connectChannel(String channelId) {}

  @override
  void disconnectChannel(String channelId) {}

  @override
  void subscribeNote(String noteId) {}

  @override
  void unsubscribeNote(String noteId) {}

  @override
  Stream<dynamic> get messages => const Stream<dynamic>.empty();
}

/// テスト用のモックNoteActionsクラス
class _MockNoteActions implements NoteActions {
  Note? lastTappedNote;
  String? lastTappedEmoji;
  String? lastTappedReaction;
  User? lastTappedUser;

  @override
  Future<void> onNoteTap(Note note) async {
    lastTappedNote = note;
  }

  @override
  Future<void> onReply(Note note) async {}

  @override
  Future<void> onRenote(Note note) async {}

  @override
  Future<void> onReaction(Note note) async {}

  @override
  Future<void> onReactionChipTap(Note note, String reaction) async {
    lastTappedNote = note;
    lastTappedReaction = reaction;
  }

  @override
  Future<void> onUserTap(User user) async {
    lastTappedUser = user;
  }

  @override
  Future<void> onBodyEmojiTap(Note note, String emoji) async {
    lastTappedNote = note;
    lastTappedEmoji = emoji;
  }

  @override
  Future<void> onReplyNoteTap(Note reply) async {}
}
