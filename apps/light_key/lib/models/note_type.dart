enum NoteType {
  /// 通常ノート（renote なし）
  normal,

  /// 純粋リノート（本文なし・renote あり）
  pureRenote,

  /// 引用リノート（本文あり・renote あり）
  quoteRenote,
}
