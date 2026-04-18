extension type NotificationTime._(DateTime value) {
  String get hour => value.hour.toString().padLeft(2, '0');
  String get minute => value.minute.toString().padLeft(2, '0');

  static NotificationTime of(int hour, int minute) =>
      NotificationTime._(DateTime(1970, 1, 1, hour, minute));

  static NotificationTime fromJson(String? json) {
    if (json == null) return NotificationTime.of(0, 0);
    final parts = json.split(':');
    if (parts.length != 2) return NotificationTime.of(0, 0);
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    return NotificationTime.of(hour, minute);
  }

  static String? toJson(NotificationTime? time) {
    if (time == null) return null;
    return '${time.hour}:${time.minute}';
  }
}