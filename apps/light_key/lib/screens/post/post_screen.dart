import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../sheets/reaction_picker/reaction_picker_sheet.dart';
import 'post_provider.dart';
import 'post_screen_state.dart';

typedef ReactionPickerLauncher = Future<String?> Function(BuildContext context);

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
    final start = selection.isValid ? clampOffset(selection.start) : value.text.length;
    final end = selection.isValid ? clampOffset(selection.end) : value.text.length;
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
      textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textController = useTextEditingController();
    final focusNode = useFocusNode();
    final state = context.watch<PostProvider>().state;

    return Scaffold(
      appBar: AppBar(
        actions: [
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
              onPressed: () => _onEmojiPickerPressed(
                context,
                textController,
                focusNode,
              ),
              icon: const Icon(Icons.emoji_emotions_outlined),
              label: const Text('絵文字を挿入'),
            ),
          ),
          if (state.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(state.message!),
            ),
        ],
      ),
    );
  }
}
