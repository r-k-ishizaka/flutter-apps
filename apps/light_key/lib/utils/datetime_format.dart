extension DateTimeDisplayExtension on DateTime {
  /// UTC の DateTime をローカル時刻に変換して "M/d H:mm" 形式で返す。
  String toNoteLabel() {
    final local = toLocal();
    return '${local.month}/${local.day} ${local.hour}:${local.minute.toString().padLeft(2, '0')}';
  }
}
