class NoteFileProperties {
  const NoteFileProperties({required this.width, required this.height});

  final int width;
  final int height;

  factory NoteFileProperties.fromJson(Map<String, dynamic> json) {
    return NoteFileProperties(
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }
}
