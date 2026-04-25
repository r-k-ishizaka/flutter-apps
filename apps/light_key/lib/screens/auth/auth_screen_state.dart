import '../../models/auth_session.dart';
import '../../models/user.dart';

enum AuthStatus { idle, loading, authenticated, error }

class AuthScreenState {
  const AuthScreenState({
    required this.status,
    this.user,
    this.session,
    this.message,
  });

  const AuthScreenState.idle()
    : status = AuthStatus.idle,
      user = null,
      session = null,
      message = null;

  final AuthStatus status;
  final User? user;
  final AuthSession? session;
  final String? message;

  AuthScreenState copyWith({
    AuthStatus? status,
    User? user,
    AuthSession? session,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthScreenState(
      status: status ?? this.status,
      user: user ?? this.user,
      session: session ?? this.session,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
