enum PostStatus { idle, submitting, success, error }

class PostScreenState {
  const PostScreenState({required this.status, this.message});

  const PostScreenState.idle() : status = PostStatus.idle, message = null;

  final PostStatus status;
  final String? message;

  PostScreenState copyWith({
    PostStatus? status,
    String? message,
    bool clearMessage = false,
  }) {
    return PostScreenState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
