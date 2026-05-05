import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_screen_state.freezed.dart';

enum PostVisibility { public, home, follower }

@freezed
sealed class PostScreenState with _$PostScreenState {
  const factory PostScreenState.idle() = PostScreenStateIdle;

  const factory PostScreenState.submitting() = PostScreenStateSubmitting;

  const factory PostScreenState.error({required String message}) =
      PostScreenStateError;
}
