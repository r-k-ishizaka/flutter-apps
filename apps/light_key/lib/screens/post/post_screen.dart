import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import '../../models/note.dart';
import '../../models/user.dart';
import '../../services/emoji_cache.dart';
import '../../sheets/reaction_picker/reaction_picker_sheet.dart';
import '../../widgets/timeline_note_item.dart';
import 'post_effect_state.dart';
import 'post_provider.dart';
import 'post_screen_state.dart';

typedef ReactionPickerLauncher = Future<String?> Function(BuildContext context);

class _EmojiSuggestionQuery {
  const _EmojiSuggestionQuery({
    required this.replaceStart,
    required this.replaceEnd,
    required this.query,
  });

  final int replaceStart;
  final int replaceEnd;
  final String query;
}

class _EmojiSuggestionItem {
  const _EmojiSuggestionItem({required this.name, this.previewUrl});

  final String name;
  final String? previewUrl;
}

class _CaretMetrics {
  const _CaretMetrics({required this.offset, required this.lineHeight});

  final Offset offset;
  final double lineHeight;
}

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
  const PostScreen({
    super.key,
    this.pickReaction = showReactionPickerSheet,
    this.replyToId,
    this.replyToUserName,
    this.replyToDisplayName,
    this.replyToText,
    this.replyToAvatarUrl,
  });

  final ReactionPickerLauncher pickReaction;
  final String? replyToId;
  final String? replyToUserName;
  final String? replyToDisplayName;
  final String? replyToText;
  final String? replyToAvatarUrl;
  static final RegExp _emojiQueryPattern = RegExp(r'^[a-zA-Z0-9_.-]*$');
  static const EdgeInsets _textFieldContentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  );
  static const double _emojiSuggestionMenuMinWidth = 168;
  static const double _emojiSuggestionMenuMaxWidth = 260;
  static const double _emojiSuggestionMenuMaxHeight = 192;
  static const double _emojiSuggestionTileHeight = 36;
  static const double _emojiSuggestionFallbackIconSize = 16;
  static const double _emojiSuggestionGap = 4;
  static const double _emojiSuggestionViewportMargin = 8;

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

  static TextEditingValue _replaceTextRange(
    TextEditingValue value,
    TextRange range,
    String replacement,
  ) {
    int clampOffset(int offset) {
      if (offset < 0) return 0;
      if (offset > value.text.length) return value.text.length;
      return offset;
    }

    final start = clampOffset(range.start);
    final end = clampOffset(range.end);
    if (start > end) return value;

    final newText = value.text.replaceRange(start, end, replacement);
    final collapsedOffset = start + replacement.length;

    return value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: collapsedOffset),
      composing: TextRange.empty,
    );
  }

  static _EmojiSuggestionQuery? _detectEmojiSuggestionQuery(
    TextEditingValue value,
  ) {
    final selection = value.selection;
    if (!selection.isValid || !selection.isCollapsed) return null;

    final cursor = selection.baseOffset;
    if (cursor <= 0 || cursor > value.text.length) return null;

    final textBeforeCursor = value.text.substring(0, cursor);
    final colonIndex = textBeforeCursor.lastIndexOf(':');
    if (colonIndex < 0) return null;

    final query = textBeforeCursor.substring(colonIndex + 1);
    if (!_emojiQueryPattern.hasMatch(query)) return null;

    // :name: の末尾 : の直後では候補表示しない
    // カーソル直前が : で、クエリが空の場合は完成した絵文字の直後
    if (query.isEmpty && cursor > 0 && value.text[cursor - 1] == ':') {
      return null;
    }

    return _EmojiSuggestionQuery(
      replaceStart: colonIndex,
      replaceEnd: cursor,
      query: query,
    );
  }

  static List<_EmojiSuggestionItem> _buildEmojiSuggestionItems(
    Map<String, EmojiCacheEntry> entries,
  ) {
    final itemMap = <String, _EmojiSuggestionItem>{};

    for (final entry in entries.entries) {
      final key = entry.key;
      if (key.isEmpty) continue;

      final atIndex = key.indexOf('@');
      final bareName = atIndex >= 0 ? key.substring(0, atIndex) : key;
      if (bareName.isEmpty) continue;

      final item = _EmojiSuggestionItem(
        name: bareName,
        previewUrl: entry.value.url.isNotEmpty ? entry.value.url : null,
      );

      if (atIndex < 0) {
        itemMap[bareName] = item;
      } else {
        itemMap.putIfAbsent(bareName, () => item);
      }
    }

    final sorted = itemMap.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return sorted;
  }

  static List<_EmojiSuggestionItem> _filterEmojiCandidates(
    List<_EmojiSuggestionItem> allItems,
    String query,
  ) {
    const maxResults = 6;
    if (query.isEmpty) {
      return allItems.take(maxResults).toList();
    }

    final lowerQuery = query.toLowerCase();
    return allItems
        .where((item) => item.name.toLowerCase().startsWith(lowerQuery))
        .take(maxResults)
        .toList();
  }

  static _CaretMetrics _estimateCaretMetrics({
    required TextEditingValue value,
    required TextStyle textStyle,
    required TextDirection textDirection,
    required double textAreaWidth,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: value.text, style: textStyle),
      textDirection: textDirection,
      maxLines: null,
    )..layout(maxWidth: textAreaWidth);

    final caretOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: value.selection.baseOffset),
      Rect.zero,
    );

    return _CaretMetrics(
      offset: Offset(
        caretOffset.dx + _textFieldContentPadding.left,
        caretOffset.dy + _textFieldContentPadding.top,
      ),
      lineHeight: textPainter.preferredLineHeight,
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
    TextEditingController bodyTextController,
    String? cw,
    String? replyId,
  ) async {
    await context
        .read<PostProvider>()
        .submit(text: bodyTextController.text, cw: cw, replyId: replyId);
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
                  trailing: option == PostVisibility.public
                      ? const Icon(Icons.check)
                      : null,
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
    final hasReplyContext = replyToId != null && replyToId!.isNotEmpty;
    final normalizedReplyUserName =
        replyToUserName == null || replyToUserName!.trim().isEmpty
        ? 'unknown'
        : replyToUserName!.trim();
    final normalizedReplyDisplayName =
        replyToDisplayName == null || replyToDisplayName!.trim().isEmpty
        ? normalizedReplyUserName
        : replyToDisplayName!.trim();
    final normalizedReplyText =
        replyToText == null || replyToText!.trim().isEmpty
        ? ''
        : replyToText!.trim();
    final bodyTextController = useTextEditingController();
    final cwTextController = useTextEditingController();
    final bodyTextValue = useValueListenable(bodyTextController);
    final cwTextValue = useValueListenable(cwTextController);
    final bodyFocusNode = useFocusNode();
    final cwFocusNode = useFocusNode();
    useListenable(bodyFocusNode);
    useListenable(cwFocusNode);
    final isCwEnabled = useState(false);
    final bodyTextFieldAnchorKey = useMemoized(GlobalKey.new);
    final cwTextFieldAnchorKey = useMemoized(GlobalKey.new);
    final suggestionOverlayRef = useRef<OverlayEntry?>(null);
    final provider = context.watch<PostProvider>();
    final state = provider.state;
    final visibility = provider.visibility;
    final isFederated = provider.isFederated;
    final effectState = context.select<PostProvider, PostEffectState>(
      (p) => p.effectState,
    );
    final previewCreatedAt = useMemoized(DateTime.now);
    final emojiEntries = context.read<EmojiCache>().entries;
    final emojiCandidates = _buildEmojiSuggestionItems(emojiEntries);
    final activeTextController = cwFocusNode.hasFocus
        ? cwTextController
        : bodyTextController;
    final activeFocusNode = cwFocusNode.hasFocus ? cwFocusNode : bodyFocusNode;
    final activeTextFieldAnchorKey =
        cwFocusNode.hasFocus && isCwEnabled.value
        ? cwTextFieldAnchorKey
        : bodyTextFieldAnchorKey;
    final activeTextValue = activeTextController.value;
    final emojiQuery = _detectEmojiSuggestionQuery(activeTextValue);
    final emojiSuggestions = emojiQuery != null
        ? _filterEmojiCandidates(emojiCandidates, emojiQuery.query)
        : const <_EmojiSuggestionItem>[];

    void closeSuggestionOverlay() {
      suggestionOverlayRef.value?.remove();
      suggestionOverlayRef.value = null;
    }

    void selectEmojiSuggestion(_EmojiSuggestionItem item) {
      final latestQuery = _detectEmojiSuggestionQuery(activeTextController.value);
      if (latestQuery == null) return;

      activeTextController.value = _replaceTextRange(
        activeTextController.value,
        TextRange(start: latestQuery.replaceStart, end: latestQuery.replaceEnd),
        ':${item.name}:',
      );
      activeFocusNode.requestFocus();
      closeSuggestionOverlay();
    }

    // 初期化時に状態をリセット
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<PostProvider>().reset();
        }
      });
      return null;
    }, []);

    useEffect(() {
      if (effectState == const PostEffectState.none()) return null;

      // Effectは一度だけ消費し、画面副作用はフレーム後に実行する。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        context.read<PostProvider>().consumeEffect();

        switch (effectState) {
          case PostEffectStateNone():
            break;
          case PostEffectStateCloseWithMessage(:final message):
            Navigator.of(context).pop(message);
            break;
          case PostEffectStateShowError(:final message):
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
            break;
        }
      });

      return null;
    }, [effectState]);

    useEffect(
      () {
        closeSuggestionOverlay();

        if (emojiQuery == null || emojiSuggestions.isEmpty) {
          return null;
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          if (suggestionOverlayRef.value != null) return;

          final anchorContext = activeTextFieldAnchorKey.currentContext;
          final anchorBox = anchorContext?.findRenderObject() as RenderBox?;
          final anchorSize = anchorBox?.size ?? Size.zero;
          final overlayState = Overlay.maybeOf(context, rootOverlay: true);
          if (overlayState == null) return;

          final textStyle =
              Theme.of(context).textTheme.bodyLarge ??
              const TextStyle(fontSize: 16, height: 1.4);
          final textAreaWidth =
              (anchorSize.width -
                      _textFieldContentPadding.left -
                      _textFieldContentPadding.right)
                  .clamp(1.0, double.infinity);
          final caretMetrics = _estimateCaretMetrics(
            value: activeTextController.value,
            textStyle: textStyle,
            textDirection: Directionality.of(context),
            textAreaWidth: textAreaWidth,
          );
          final menuWidth = anchorSize.width
              .clamp(_emojiSuggestionMenuMinWidth, _emojiSuggestionMenuMaxWidth)
              .toDouble();
          final maxDx = (anchorSize.width - menuWidth).clamp(
            0.0,
            double.infinity,
          );
          final menuDx = caretMetrics.offset.dx.clamp(0.0, maxDx);

          final overlayBox =
              overlayState.context.findRenderObject() as RenderBox?;
          if (overlayBox == null) return;

          final anchorTopInOverlay =
              anchorBox?.localToGlobal(Offset.zero, ancestor: overlayBox) ??
              Offset.zero;
          final anchorLeftInOverlay = anchorTopInOverlay.dx;
          final mediaQuery = MediaQuery.of(context);
          final keyboardInset = mediaQuery.viewInsets.bottom;
          final maxVisibleBottom =
              overlayBox.size.height -
              keyboardInset -
              _emojiSuggestionViewportMargin;
          final caretTopInOverlay =
              anchorTopInOverlay.dy + caretMetrics.offset.dy;
          final belowStart =
              caretTopInOverlay + caretMetrics.lineHeight + _emojiSuggestionGap;

          final availableBelow = (maxVisibleBottom - belowStart).clamp(
            0.0,
            double.infinity,
          );
          final availableAbove =
              (caretTopInOverlay -
                      _emojiSuggestionGap -
                      _emojiSuggestionViewportMargin)
                  .clamp(0.0, double.infinity);
          final showAbove =
              availableBelow < _emojiSuggestionTileHeight &&
              availableAbove > availableBelow;
          final effectiveMenuMaxHeight =
              (showAbove ? availableAbove : availableBelow)
                  .clamp(
                    _emojiSuggestionTileHeight,
                    _emojiSuggestionMenuMaxHeight,
                  )
                  .toDouble();
          final desiredMenuHeight =
              (emojiSuggestions.length * _emojiSuggestionTileHeight)
                  .clamp(
                    _emojiSuggestionTileHeight,
                    _emojiSuggestionMenuMaxHeight,
                  )
                  .toDouble();
          final menuHeight = desiredMenuHeight < effectiveMenuMaxHeight
              ? desiredMenuHeight
              : effectiveMenuMaxHeight;

          final rawMenuTopInOverlay = showAbove
              ? caretTopInOverlay - _emojiSuggestionGap - menuHeight
              : belowStart;
          final maxMenuTopInOverlay = (maxVisibleBottom - menuHeight).clamp(
            _emojiSuggestionViewportMargin,
            double.infinity,
          );
          final menuTopInOverlay = rawMenuTopInOverlay.clamp(
            _emojiSuggestionViewportMargin,
            maxMenuTopInOverlay,
          );

          final rawMenuLeftInOverlay = anchorLeftInOverlay + menuDx;
          final maxMenuLeftInOverlay =
              (overlayBox.size.width -
                      _emojiSuggestionViewportMargin -
                      menuWidth)
                  .clamp(_emojiSuggestionViewportMargin, double.infinity);
          final menuLeftInOverlay = rawMenuLeftInOverlay.clamp(
            _emojiSuggestionViewportMargin,
            maxMenuLeftInOverlay,
          );

          final overlayEntry = OverlayEntry(
            builder: (overlayContext) {
              final theme = Theme.of(overlayContext);

              return Stack(
                children: [
                  Positioned(
                    left: menuLeftInOverlay,
                    top: menuTopInOverlay,
                    child: Material(
                      key: const ValueKey('post-emoji-suggestion-menu'),
                      elevation: 6,
                      borderRadius: BorderRadius.circular(12),
                      color: theme.colorScheme.surface,
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox(
                        width: menuWidth,
                        height: menuHeight,
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: emojiSuggestions.length,
                          itemExtent: _emojiSuggestionTileHeight,
                          itemBuilder: (_, index) {
                            final item = emojiSuggestions[index];

                            return Material(
                              key: ValueKey(
                                'post-emoji-suggestion-item-${item.name}',
                              ),
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => selectEmojiSuggestion(item),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 0,
                                        child: Center(
                                          child: SizedBox(
                                            width: 32,
                                            height:
                                                _emojiSuggestionTileHeight - 8,
                                            child: item.previewUrl == null
                                                ? const Icon(
                                                    Icons.tag_faces_outlined,
                                                    size:
                                                        _emojiSuggestionFallbackIconSize,
                                                  )
                                                : Image.network(
                                                    item.previewUrl!,
                                                    fit: BoxFit.contain,
                                                    alignment: Alignment.center,
                                                    errorBuilder: (_, _, _) =>
                                                        const Icon(
                                                          Icons
                                                              .tag_faces_outlined,
                                                          size:
                                                              _emojiSuggestionFallbackIconSize,
                                                        ),
                                                  ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          ':${item.name}:',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );

          overlayState.insert(overlayEntry);
          suggestionOverlayRef.value = overlayEntry;
        });

        return closeSuggestionOverlay;
      },
      [
        isCwEnabled.value,
        bodyFocusNode.hasFocus,
        cwFocusNode.hasFocus,
        emojiQuery?.replaceStart,
        emojiQuery?.replaceEnd,
        emojiQuery?.query,
        emojiSuggestions.join(','),
      ],
    );

    final previewNote = Note(
      id: 'post-preview',
      text: bodyTextValue.text,
      cw: isCwEnabled.value ? cwTextValue.text : null,
      createdAt: previewCreatedAt,
      user: const User(id: 'post-preview-user', username: 'you', name: 'あなた'),
      reply: hasReplyContext
          ? Note(
              id: 'post-preview-reply',
              text: normalizedReplyText,
              createdAt: previewCreatedAt,
              user: User(
                id: 'post-preview-reply-user',
                username: normalizedReplyUserName,
                name: normalizedReplyDisplayName,
                avatarUrl: replyToAvatarUrl ?? '',
              ),
            )
          : null,
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
            tooltip: '公開範囲: ${visibility.label}',
            onPressed: state is PostScreenStateSubmitting
                ? null
                : () => _showVisibilityPicker(context),
            icon: Icon(visibility.icon),
          ),
          IconButton(
            key: const ValueKey('post-federation-toggle-button'),
            tooltip: '連合: ${isFederated ? 'あり' : 'なし'}',
            onPressed: state is PostScreenStateSubmitting
                ? null
                : () => _toggleFederation(context, isFederated),
            icon: _buildFederationIcon(context, isFederated),
          ),
          TextButton(
            key: const ValueKey('post-submit-button'),
            onPressed: state is PostScreenStateSubmitting
                ? null
                : () => _submitPost(
                    context,
                    bodyTextController,
                    isCwEnabled.value ? cwTextController.text : null,
                    hasReplyContext ? replyToId : null,
                  ),
            child: state is PostScreenStateSubmitting
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
          if (hasReplyContext)
            _ReplyTargetCard(
              userName: replyToUserName,
              text: replyToText,
            ),
          if (hasReplyContext) const SizedBox(height: 12),
          if (isCwEnabled.value)
            Container(
              key: cwTextFieldAnchorKey,
              child: TextField(
                key: const ValueKey('post-cw-text-field'),
                autofocus: true,
                controller: cwTextController,
                focusNode: cwFocusNode,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: 'CW (内容の警告)',
                  contentPadding: _textFieldContentPadding,
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          if (isCwEnabled.value) const SizedBox(height: 12),
          Container(
            key: bodyTextFieldAnchorKey,
            child: TextField(
              key: const ValueKey('post-body-text-field'),
              autofocus: !isCwEnabled.value,
              controller: bodyTextController,
              focusNode: bodyFocusNode,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: isCwEnabled.value ? '本文を入力' : 'いまどうしてる？',
                contentPadding: _textFieldContentPadding,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton.icon(
                key: const ValueKey('post-emoji-picker-button'),
                onPressed: () => _onEmojiPickerPressed(
                  context,
                  activeTextController,
                  activeFocusNode,
                ),
                icon: const Icon(Icons.emoji_emotions_outlined),
                label: const Text('絵文字を挿入'),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const ValueKey('post-cw-toggle-button'),
                tooltip: 'CW: ${isCwEnabled.value ? 'オン' : 'オフ'}',
                onPressed: state is PostScreenStateSubmitting
                    ? null
                    : () {
                        isCwEnabled.value = !isCwEnabled.value;
                        if (isCwEnabled.value) {
                          cwFocusNode.requestFocus();
                        } else {
                          bodyFocusNode.requestFocus();
                        }
                      },
                icon: Icon(
                  isCwEnabled.value ? Icons.visibility : Icons.visibility_off,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('プレビュー'),
          TimelineNoteItem(
            key: const ValueKey('post-note-preview'),
            note: previewNote,
            emojis: context.read<EmojiCache>().entries,
            animation: const AlwaysStoppedAnimation(1),
          ),
          if (state case PostScreenStateError(:final message))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(message),
            ),
        ],
      ),
    );
  }
}

class _ReplyTargetCard extends StatelessWidget {
  const _ReplyTargetCard({this.userName, this.text});

  final String? userName;
  final String? text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedUserName = (userName == null || userName!.trim().isEmpty)
        ? null
        : userName!.trim();
    final normalizedText = (text == null || text!.trim().isEmpty)
        ? '(本文なし)'
        : text!.trim();

    return Container(
      key: const ValueKey('post-reply-target-card'),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.reply, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  normalizedUserName == null
                      ? '返信先'
                      : '返信先: @$normalizedUserName',
                  key: const ValueKey('post-reply-target-user'),
                  style: theme.textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  normalizedText,
                  key: const ValueKey('post-reply-target-text'),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
