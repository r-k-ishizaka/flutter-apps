import '../../models/note.dart';
import '../../models/user_profile.dart';

enum ProfileStatus { idle, loading, loaded, error }

class ProfileScreenState {
  const ProfileScreenState({
    required this.status,
    this.profile,
    this.message,
    this.allNotes = const <Note>[],
    this.noteOnlyNotes = const <Note>[],
    this.mediaNotes = const <Note>[],
    this.allNotesUntilId,
    this.noteOnlyNotesUntilId,
    this.mediaNotesUntilId,
    this.isLoadingMoreAllNotes = false,
    this.isLoadingMoreNoteOnlyNotes = false,
    this.isLoadingMoreMediaNotes = false,
  });

  const ProfileScreenState.idle()
    : status = ProfileStatus.idle,
      profile = null,
      message = null,
      allNotes = const <Note>[],
      noteOnlyNotes = const <Note>[],
      mediaNotes = const <Note>[],
      allNotesUntilId = null,
      noteOnlyNotesUntilId = null,
      mediaNotesUntilId = null,
      isLoadingMoreAllNotes = false,
      isLoadingMoreNoteOnlyNotes = false,
      isLoadingMoreMediaNotes = false;

  final ProfileStatus status;
  final UserProfile? profile;
  final String? message;
  final List<Note> allNotes;
  final List<Note> noteOnlyNotes;
  final List<Note> mediaNotes;
  final String? allNotesUntilId;
  final String? noteOnlyNotesUntilId;
  final String? mediaNotesUntilId;
  final bool isLoadingMoreAllNotes;
  final bool isLoadingMoreNoteOnlyNotes;
  final bool isLoadingMoreMediaNotes;

  ProfileScreenState copyWith({
    ProfileStatus? status,
    UserProfile? profile,
    String? message,
    List<Note>? allNotes,
    List<Note>? noteOnlyNotes,
    List<Note>? mediaNotes,
    String? allNotesUntilId,
    String? noteOnlyNotesUntilId,
    String? mediaNotesUntilId,
    bool? isLoadingMoreAllNotes,
    bool? isLoadingMoreNoteOnlyNotes,
    bool? isLoadingMoreMediaNotes,
    bool clearMessage = false,
    bool clearProfile = false,
    bool clearNotes = false,
  }) {
    return ProfileScreenState(
      status: status ?? this.status,
      profile: clearProfile ? null : (profile ?? this.profile),
      message: clearMessage ? null : (message ?? this.message),
      allNotes: clearNotes ? const <Note>[] : (allNotes ?? this.allNotes),
      noteOnlyNotes: clearNotes
          ? const <Note>[]
          : (noteOnlyNotes ?? this.noteOnlyNotes),
      mediaNotes: clearNotes ? const <Note>[] : (mediaNotes ?? this.mediaNotes),
      allNotesUntilId: allNotesUntilId ?? this.allNotesUntilId,
      noteOnlyNotesUntilId: noteOnlyNotesUntilId ?? this.noteOnlyNotesUntilId,
      mediaNotesUntilId: mediaNotesUntilId ?? this.mediaNotesUntilId,
      isLoadingMoreAllNotes:
          isLoadingMoreAllNotes ?? this.isLoadingMoreAllNotes,
      isLoadingMoreNoteOnlyNotes:
          isLoadingMoreNoteOnlyNotes ?? this.isLoadingMoreNoteOnlyNotes,
      isLoadingMoreMediaNotes:
          isLoadingMoreMediaNotes ?? this.isLoadingMoreMediaNotes,
    );
  }
}
