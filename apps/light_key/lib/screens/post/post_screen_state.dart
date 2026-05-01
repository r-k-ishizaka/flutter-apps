enum PostStatus { idle, submitting, success, error }

enum PostVisibility { public, home, follower }

class PostScreenState {
  const PostScreenState({
    required this.status,
    required this.visibility,
    this.message,
  });

  const PostScreenState.idle()
    : status = PostStatus.idle,
      visibility = PostVisibility.public,
      message = null;

  final PostStatus status;
  final PostVisibility visibility;
  final String? message;

  PostScreenState copyWith({
    PostStatus? status,
    PostVisibility? visibility,
    String? message,
    bool clearMessage = false,
  }) {
    return PostScreenState(
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
