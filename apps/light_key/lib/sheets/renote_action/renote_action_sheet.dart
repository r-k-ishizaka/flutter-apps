import 'package:flutter/material.dart';

enum RenoteAction { renote, quote }

/// リノート操作を選択するボトムシート。
Future<RenoteAction?> showRenoteActionSheet(BuildContext context) {
  return showModalBottomSheet<RenoteAction>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.repeat),
              title: const Text('リノート'),
              onTap: () => Navigator.of(context).pop(RenoteAction.renote),
            ),
            ListTile(
              leading: const Icon(Icons.format_quote),
              title: const Text('引用'),
              onTap: () => Navigator.of(context).pop(RenoteAction.quote),
            ),
          ],
        ),
      );
    },
  );
}
