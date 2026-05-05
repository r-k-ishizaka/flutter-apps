import 'package:flutter_test/flutter_test.dart';
import 'package:light_key/datasources/auth_data_source.dart';
import 'package:light_key/datasources/timeline_connection.dart';
import 'package:light_key/datasources/timeline_data_source.dart';
import 'package:light_key/datasources/user_profile_data_source.dart';
import 'package:light_key/models/auth_session.dart';
import 'package:light_key/models/note.dart';
import 'package:light_key/models/response_with_cache_hints.dart';
import 'package:light_key/models/user.dart';
import 'package:light_key/models/user_profile.dart';
import 'package:light_key/repositories/auth_repository.dart';
import 'package:light_key/repositories/timeline_repository.dart';
import 'package:light_key/repositories/user_profile_repository.dart';
import 'package:light_key/screens/profile/profile_provider.dart';

void main() {
  group('ProfileProvider.createReaction', () {
    test('通常ノートにリアクションを送信する', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
      );

      final message = await provider.provider.createReaction(
        _note(id: 'note-1'),
        '👍',
      );

      expect(message, isNull);
      expect(provider.timelineDataSource.reactionCalls, [('note-1', '👍')]);
    });

    test('純粋リノートでは元ノートにリアクションを送信する', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
      );
      final pureRenote = Note(
        id: 'renote-wrapper',
        text: '',
        createdAt: DateTime(2026, 4, 28, 12),
        user: const User(id: 'user-2', username: 'bob', name: 'Bob'),
        renote: _note(id: 'renoted-note'),
      );

      final message = await provider.provider.createReaction(
        pureRenote,
        ':custom:',
      );

      expect(message, isNull);
      expect(provider.timelineDataSource.reactionCalls, [
        ('renoted-note', ':custom:'),
      ]);
    });

    test('互換入力の :name@.: は :name: に変換して送信する', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
      );

      final message = await provider.provider.createReaction(
        _note(id: 'note-1'),
        ':blob_bongo_cat_keyboard@.:',
      );

      expect(message, isNull);
      expect(provider.timelineDataSource.reactionCalls, [
        ('note-1', ':blob_bongo_cat_keyboard:'),
      ]);
    });

    test('未認証時はエラーメッセージを返す', () async {
      final provider = _buildProvider();

      final message = await provider.provider.createReaction(
        _note(id: 'note-1'),
        '👍',
      );

      expect(message, '先に認証してください。');
      expect(provider.timelineDataSource.reactionCalls, isEmpty);
    });
  });

  group('ProfileProvider.createRenote', () {
    test('通常ノートをリノート送信する', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
      );

      final message = await provider.createRenote(_note(id: 'note-1'));

      expect(message, isNull);
      expect(provider.timelineDataSource.renoteCalls, ['note-1']);
    });

    test('純粋リノートでは元ノートにリノート送信する', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
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
      expect(provider.timelineDataSource.renoteCalls, ['renoted-note']);
    });

    test('未認証時はエラーメッセージを返す', () async {
      final provider = _buildProvider();

      final message = await provider.createRenote(_note(id: 'note-1'));

      expect(message, '先に認証してください。');
      expect(provider.timelineDataSource.renoteCalls, isEmpty);
    });

    test('対象ノートIDが空のときはエラーメッセージを返す', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
      );

      final message = await provider.createRenote(_note(id: ''));

      expect(message, 'リノート対象のノートIDが見つかりません。');
      expect(provider.timelineDataSource.renoteCalls, isEmpty);
    });

    test('送信失敗時はエラーメッセージを返す', () async {
      final provider = _buildProvider(
        authSession: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
        renoteError: Exception('network error'),
      );

      final message = await provider.createRenote(_note(id: 'note-1'));

      expect(message, startsWith('リノート送信に失敗しました:'));
      expect(provider.timelineDataSource.renoteCalls, ['note-1']);
    });
  });
}

_NamedProvider _buildProvider({
  AuthSession? authSession,
  Exception? renoteError,
}) {
  final timelineDataSource = _FakeTimelineDataSource(renoteError: renoteError);
  final provider = ProfileProvider(
    authRepository: AuthRepository(_FakeAuthDataSource(session: authSession)),
    profileRepository: UserProfileRepository(_FakeUserProfileDataSource()),
    timelineRepository: TimelineRepository(timelineDataSource),
  );
  return _NamedProvider(provider: provider, timelineDataSource: timelineDataSource);
}

class _NamedProvider {
  _NamedProvider({required this.provider, required this.timelineDataSource});

  final ProfileProvider provider;
  final _FakeTimelineDataSource timelineDataSource;

  Future<String?> createRenote(Note note) => provider.createRenote(note);
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
  }) async =>
      throw UnimplementedError();

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
        data: User(
          id: 'user-1',
          username: 'sample_user',
          name: 'Sample User',
        ),
      );
}

class _FakeUserProfileDataSource implements UserProfileDataSource {
  @override
  Future<ResponseWithCacheHints<UserProfile>> fetchUserProfile(
    AuthSession session,
    String userId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchUserNotes(
    AuthSession session,
    String userId, {
    int limit = 50,
    bool withReplies = true,
    bool withRenotes = true,
    bool withFiles = false,
    bool withChannelNotes = true,
    bool allowPartial = false,
    String? untilId,
  }) async =>
      throw UnimplementedError();
}

class _FakeTimelineDataSource implements TimelineDataSource {
  _FakeTimelineDataSource({this.renoteError});

  final Exception? renoteError;
  final List<(String noteId, String reaction)> reactionCalls = [];
  final List<String> renoteCalls = [];

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
    if (renoteError != null) {
      throw renoteError!;
    }
  }

  @override
  Future<ResponseWithCacheHints<Note>> fetchNote(
    AuthSession session,
    String noteId,
  ) async =>
      ResponseWithCacheHints(data: _note(id: noteId));

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async =>
      const ResponseWithCacheHints(data: <Note>[]);

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
  Stream<dynamic> get messages => const Stream<dynamic>.empty();

  @override
  void subscribeNote(String noteId) {}

  @override
  void unsubscribeNote(String noteId) {}
}
