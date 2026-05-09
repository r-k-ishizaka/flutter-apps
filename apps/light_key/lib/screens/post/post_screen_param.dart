import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_screen_param.freezed.dart';

/// 投稿画面のパラメータ。通常投稿・リプライ・引用リノートを型で区別する。
@freezed
sealed class PostScreenParam with _$PostScreenParam {
  /// 通常投稿（リプライも引用リノートもなし）
  const factory PostScreenParam.normal() = PostScreenParamNormal;

  /// リプライ投稿
  const factory PostScreenParam.reply({
    required String targetId,
    required String userName,
    required String displayName,
    required String text,
    String? avatarUrl,
  }) = PostScreenParamReply;

  /// 引用リノート投稿
  const factory PostScreenParam.quote({
    required String targetId,
    required String userName,
    required String displayName,
    required String text,
    String? avatarUrl,
  }) = PostScreenParamQuote;
}
