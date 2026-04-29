import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:provider/provider.dart';

import 'reaction_picker_body.dart';
import 'reaction_picker_provider.dart';

/// リアクション選択ボトムシート。
///
/// [showReactionPickerSheet] を呼び出して表示する。
/// ユーザーが絵文字を選択すると [onSelected] が呼ばれる。
class ReactionPickerSheet extends HookWidget {
  const ReactionPickerSheet({required this.onSelected, super.key});

  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final notifier = useMemoized(ReactionPickerProvider.new);
    useEffect(() => notifier.dispose, [notifier]);

    return ChangeNotifierProvider<ReactionPickerProvider>.value(
      value: notifier,
      child: ReactionPickerBody(onSelected: onSelected),
    );
  }
}

/// リアクション選択ボトムシートを表示するユーティリティ関数。
///
/// ShellRoute 配下の画面から呼ばれる前提のため、常にルート Navigator
/// に表示して AppBar / NavigationBar より前面に重ねる。
///
/// ユーザーが絵文字を選択した場合はその文字列が返り、
/// キャンセルした場合は `null` が返る。
Future<String?> showReactionPickerSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => ReactionPickerSheet(
      onSelected: (emoji) => Navigator.of(context).pop(emoji),
    ),
  );
}
