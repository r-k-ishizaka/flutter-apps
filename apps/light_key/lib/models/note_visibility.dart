import 'package:flutter/material.dart';

/// Misskey のノート公開範囲
enum NoteVisibility {
  /// 全体公開
  public,

  /// ホームタイムラインのみ
  home,

  /// フォロワーのみ
  followers,

  /// ダイレクト（指定ユーザーのみ）
  specified;

  factory NoteVisibility.fromJson(String? value) {
    return switch (value) {
      'public' => NoteVisibility.public,
      'home' => NoteVisibility.home,
      'followers' => NoteVisibility.followers,
      'specified' => NoteVisibility.specified,
      _ => NoteVisibility.public,
    };
  }

  /// 表示用ラベル
  String get label => switch (this) {
    NoteVisibility.public => 'パブリック',
    NoteVisibility.home => 'ホーム',
    NoteVisibility.followers => 'フォロワー',
    NoteVisibility.specified => 'ダイレクト',
  };

  /// 表示用アイコン
  IconData get icon => switch (this) {
    NoteVisibility.public => Icons.public,
    NoteVisibility.home => Icons.home_outlined,
    NoteVisibility.followers => Icons.lock_outline,
    NoteVisibility.specified => Icons.mail_outline,
  };
}
