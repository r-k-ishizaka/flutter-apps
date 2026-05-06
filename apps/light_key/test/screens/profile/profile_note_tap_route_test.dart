import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
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
import 'package:light_key/screens/profile/profile_screen.dart';
import 'package:light_key/services/emoji_cache.dart';
import 'package:provider/provider.dart';

void main() {
  group('ProfileScreen note tap routing', () {
    testWidgets('通常ノートをタップするとノート詳細へ遷移する', (tester) async {
      final note = _note(id: 'note-1', text: 'normal-note-text');
      final provider = await _buildLoadedProvider(notes: [note]);

      await tester.pumpWidget(_buildApp(provider: provider));
      await tester.pumpAndSettle();

      final noteTextFinder = find.text('normal-note-text');
      await tester.scrollUntilVisible(
        noteTextFinder,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(noteTextFinder, findsOneWidget);

      await tester.tap(noteTextFinder);
      await tester.pumpAndSettle();

      expect(find.text('note-detail:note-1'), findsOneWidget);
    });

    testWidgets('純粋リノートをタップするとリノート元IDでノート詳細へ遷移する', (tester) async {
      final renoted = _note(id: 'renoted-note', text: 'renoted-text');
      final pureRenote = Note(
        id: 'renote-wrapper',
        text: '',
        createdAt: DateTime(2026, 5, 1, 12),
        user: const User(id: 'user-2', username: 'bob', name: 'Bob'),
        renote: renoted,
      );
      final provider = await _buildLoadedProvider(notes: [pureRenote]);

      await tester.pumpWidget(_buildApp(provider: provider));
      await tester.pumpAndSettle();

      final noteTextFinder = find.text('renoted-text');
      await tester.scrollUntilVisible(
        noteTextFinder,
        400,
        scrollable: find.byType(Scrollable).first,
      );
      expect(noteTextFinder, findsOneWidget);

      await tester.tap(noteTextFinder);
      await tester.pumpAndSettle();

      expect(find.text('note-detail:renoted-note'), findsOneWidget);
    });
  });
}

Widget _buildApp({required ProfileProvider provider}) {
  final emojiCache = EmojiCache();
  final router = GoRouter(
    initialLocation: '/users/user-1',
    routes: [
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) => MultiProvider(
          providers: [
            ChangeNotifierProvider<ProfileProvider>.value(value: provider),
            Provider<EmojiCache>.value(value: emojiCache),
          ],
          child: ProfileScreen(userId: state.pathParameters['userId']!),
        ),
      ),
      GoRoute(
        path: '/notes/:noteId',
        builder: (context, state) => Scaffold(
          body: Text('note-detail:${state.pathParameters['noteId']}'),
        ),
      ),
    ],
  );

  return MaterialApp.router(routerConfig: router);
}

Future<ProfileProvider> _buildLoadedProvider({
  required List<Note> notes,
}) async {
  final provider = ProfileProvider(
    authRepository: AuthRepository(
      _FakeAuthDataSource(
        session: const AuthSession(
          baseUrl: 'https://example.com',
          accessToken: 'token',
        ),
      ),
    ),
    profileRepository: UserProfileRepository(
      _FakeUserProfileDataSource(notes: notes),
    ),
    timelineRepository: TimelineRepository(_FakeTimelineDataSource()),
  );
  await provider.load('user-1');
  return provider;
}

Note _note({required String id, required String text}) {
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

class _FakeUserProfileDataSource implements UserProfileDataSource {
  _FakeUserProfileDataSource({required this.notes});

  final List<Note> notes;

  @override
  Future<ResponseWithCacheHints<UserProfile>> fetchUserProfile(
    AuthSession session,
    String userId,
  ) async => const ResponseWithCacheHints(
    data: UserProfile(
      id: 'user-1',
      username: 'sample_user',
      name: 'Sample User',
    ),
  );

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
  }) async => ResponseWithCacheHints(data: notes);
}

class _FakeTimelineDataSource implements TimelineDataSource {
  @override
  Future<void> createReaction(
    AuthSession session, {
    required String noteId,
    required String reaction,
  }) async {}

  @override
  Future<void> createRenote(
    AuthSession session, {
    required String noteId,
  }) async {}

  @override
  Future<ResponseWithCacheHints<Note>> fetchNote(
    AuthSession session,
    String noteId,
  ) async => ResponseWithCacheHints(
    data: _note(id: noteId, text: 'detail'),
  );

  @override
  Future<ResponseWithCacheHints<List<Note>>> fetchTimeline(
    AuthSession session, {
    int limit = 20,
  }) async => const ResponseWithCacheHints(data: <Note>[]);

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
