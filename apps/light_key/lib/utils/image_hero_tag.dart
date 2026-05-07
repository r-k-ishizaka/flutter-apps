import '../models/note_file.dart';

String buildImageHeroTag({required NoteFile file, required int index}) {
  final stableId = file.id.isNotEmpty
      ? file.id
      : (file.url.isNotEmpty ? file.url : (file.thumbnailUrl ?? 'unknown'));
  return 'note-image-hero:$stableId:$index';
}
