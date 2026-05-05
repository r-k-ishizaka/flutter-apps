import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_effect_state.freezed.dart';

const String postSuccessMessage = '投稿に成功しました';

@freezed
sealed class PostEffectState with _$PostEffectState {
  const factory PostEffectState.none() = PostEffectStateNone;

  const factory PostEffectState.closeWithMessage(String message) =
      PostEffectStateCloseWithMessage;

  const factory PostEffectState.showError(String message) =
      PostEffectStateShowError;
}
