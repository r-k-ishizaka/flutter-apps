import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_viewer_screen_state.freezed.dart';

@freezed
sealed class ImageViewerScreenState with _$ImageViewerScreenState {
  /// 初期状態
  const factory ImageViewerScreenState.initial() = ImageViewerScreenStateInitial;
}
