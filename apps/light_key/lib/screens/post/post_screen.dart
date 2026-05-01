import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../models/user.dart';
import '../../sheets/reaction_picker/reaction_picker_sheet.dart';
import '../../widgets/timeline_note_item.dart';
import 'post_provider.dart';
import 'post_screen_state.dart';

typedef ReactionPickerLauncher = Future<String?> Function(BuildContext context);

const String postSuccessMessage = '投稿に成功しました';

extension on PostVisibility {
  IconData get icon {
    return switch (this) {
      PostVisibility.public => Icons.public,
      PostVisibility.home => Icons.home,
      PostVisibility.follower => Icons.lock,
    };
  }

  String get label {
    return switch (this) {
      PostVisibility.public => '公開',
      PostVisibility.home => 'ホーム',
      PostVisibility.follower => 'フォロワー',
    };
  }

  String get optionKey {
    return switch (this) {
      PostVisibility.public => 'public',
      PostVisibility.home => 'home',
      PostVisibility.follower => 'follower',
    };
  }
}

class PostScreen extends HookWidget {
  const PostScreen({super.key, this.pickReaction = showReactionPickerSheet});

  final ReactionPickerLauncher pickReaction;

  static TextEditingValue _insertTextAtSelection(
    TextEditingValue value,
    String insertedText,
  ) {
    int clampOffset(int offset) {
      if (offset < 0) return 0;
      if (offset > value.text.length) return value.text.length;
      return offset;
    }

    final selection = value.selection;
    final start = selection.isValid
        ? clampOffset(selection.start)
        : value.text.length;
    final end = selection.isValid
        ? clampOffset(selection.end)
        : value.text.length;
    final newText = value.text.replaceRange(start, end, insertedText);
    final collapsedOffset = start + insertedText.length;

    return value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: collapsedOffset),
      composing: TextRange.empty,
    );
  }

  Future<void> _onEmojiPickerPressed(
    BuildContext context,
    TextEditingController textController,
    FocusNode focusNode,
  ) async {
    final emoji = await pickReaction(context);
    if (!context.mounted || emoji == null || emoji.isEmpty) return;

    textController.value = _insertTextAtSelection(textController.value, emoji);
    focusNode.requestFocus();
  }

  Future<void> _submitPost(
    BuildContext context,
    TextEditingController textController,
  ) async {
    await context.read<PostProvider>().submit(textController.text);
    if (context.mounted &&
        context.read<PostProvider>().state.status == PostStatus.success) {
      Navigator.of(context).pop(postSuccessMessage);
    }
  }

  Future<void> _showVisibilityPicker(BuildContext context) async {
    // モーダル表示前に公開にリセット
    context.read<PostProvider>().setVisibility(PostVisibility.public);

    final selected = await showModalBottomSheet<PostVisibility>(
      context: context,
      builder: (sheetContext) {
        final options = [
          PostVisibility.public,
          PostVisibility.home,
          PostVisibility.follower,
        ];

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('公開範囲')),
              for (final option in options)
                ListTile(
                  key: ValueKey('post-visibility-option-${option.optionKey}'),
                  leading: Icon(option.icon),
                  title: Text(option.label),
                  trailing:
                      option == PostVisibility.public ? const Icon(Icons.check) : null,
                  onTap: () => Navigator.of(sheetContext).pop(option),
                ),
            ],
          ),
        );
      },
    );

    if (!context.mounted || selected == null) return;
    context.read<PostProvider>().setVisibility(selected);
  }

  void _toggleFederation(BuildContext context, bool current) {
    context.read<PostProvider>().setFederated(!current);
  }

  Widget _buildFederationIcon(BuildContext context, bool isFederated) {
    if (isFederated) {
      return const Icon(Icons.rocket_launch_outlined);
    }

    final errorColor = Theme.of(context).colorScheme.error;
    final appBarBackground =
        Theme.of(context).appBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surface;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.rocket_launch, color: errorColor),
        Transform.rotate(
          angle: 0.7,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                key: const ValueKey('post-federation-off-slash-outline'),
                width: 20,
                height: 4.6,
                decoration: BoxDecoration(
                  color: appBarBackground,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                key: const ValueKey('post-federation-off-slash'),
                width: 18,
                height: 2.2,
                decoration: BoxDecoration(
                  color: errorColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final textValue = useValueListenable(textController);
    final focusNode = useFocusNode();
    final state = context.watch<PostProvider>().state;
    final previewCreatedAt = useMemoized(DateTime.now);

    // 初期化時に公開範囲をリセット
    useEffect(() {
      context.read<PostProvider>().setVisibility(PostVisibility.public);
      context.read<PostProvider>().setFederated(true);
      return null;
    }, []);

    final previewNote = Note(
      id: 'post-preview',
      text: textValue.text,
      createdAt: previewCreatedAt,
      user: const User(id: 'post-preview-user', username: 'you', name: 'あなた'),
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('post-close-button'),
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          IconButton(
            key: const ValueKey('post-visibility-button'),
            tooltip: '公開範囲: ${state.visibility.label}',
            onPressed: state.status == PostStatus.submitting
                ? null
                : () => _showVisibilityPicker(context),
            icon: Icon(state.visibility.icon),
          ),
          IconButton(
            key: const ValueKey('post-federation-toggle-button'),
            tooltip: '連合: ${state.isFederated ? 'あり' : 'なし'}',
            onPressed: state.status == PostStatus.submitting
                ? null
                : () => _toggleFederation(context, state.isFederated),
            icon: _buildFederationIcon(context, state.isFederated),
          ),
          TextButton(
            key: const ValueKey('post-submit-button'),
            onPressed: state.status == PostStatus.submitting
                ? null
                : () => _submitPost(context, textController),
            child: state.status == PostStatus.submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('投稿'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            autofocus: true,
            controller: textController,
            focusNode: focusNode,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'いまどうしてる？',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              key: const ValueKey('post-emoji-picker-button'),
              onPressed: () =>
                  _onEmojiPickerPressed(context, textController, focusNode),
              icon: const Icon(Icons.emoji_emotions_outlined),
              label: const Text('絵文字を挿入'),
            ),
          ),
          const SizedBox(height: 8),
          const Text('プレビュー'),
          TimelineNoteItem(
            key: const ValueKey('post-note-preview'),
            note: previewNote,
            animation: const AlwaysStoppedAnimation(1),
          ),
          if (state.status == PostStatus.error && state.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.message!),
            ),
        ],
      ),
    );
  }
}
