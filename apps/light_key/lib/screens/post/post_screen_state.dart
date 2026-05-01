enum PostStatus { idle, submitting, success, error }

enum PostVisibility { public, home, follower }

class PostScreenState {
  const PostScreenState({
    required this.status,
    required this.visibility,
    required this.isFederated,
    this.message,
  });

  const PostScreenState.idle()
    : status = PostStatus.idle,
      visibility = PostVisibility.public,
      isFederated = true,
      message = null;

  final PostStatus status;
  final PostVisibility visibility;
  final bool isFederated;
  final String? message;

  PostScreenState copyWith({
    PostStatus? status,
    PostVisibility? visibility,
    bool? isFederated,
    String? message,
    bool clearMessage = false,
  }) {
    return PostScreenState(
      status: status ?? this.status,
      visibility: visibility ?? this.visibility,
      isFederated: isFederated ?? this.isFederated,
      message: clearMessage ? null : (message ?? this.message),
    );
  }
}
