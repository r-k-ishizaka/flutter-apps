import '../../models/auth_session.dart';
import '../../models/user.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthScreenState {
  const AuthScreenState({
    required this.status,
    this.user,
    this.session,
    this.message,
    this.emojiSyncProgress,
  });

  const AuthScreenState.idle()
    : status = AuthStatus.idle,
      user = null,
      session = null,
      message = null,
      emojiSyncProgress = null;

  final AuthStatus status;
  final User? user;
  final AuthSession? session;
  final String? message;
  final double? emojiSyncProgress;

  AuthScreenState copyWith({
    AuthStatus? status,
    User? user,
    AuthSession? session,
    String? message,
    double? emojiSyncProgress,
    bool clearMessage = false,
    bool clearEmojiSyncProgress = false,
  }) {
    return AuthScreenState(
      status: status ?? this.status,
      user: user ?? this.user,
      session: session ?? this.session,
      message: clearMessage ? null : (message ?? this.message),
      emojiSyncProgress: clearEmojiSyncProgress
          ? null
          : (emojiSyncProgress ?? this.emojiSyncProgress),
    );
  }
}
