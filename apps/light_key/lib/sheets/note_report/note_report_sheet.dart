import 'package:flutter/material.dart';

class NoteReportReason {
  const NoteReportReason({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class NoteReportInput {
  const NoteReportInput({
    required this.category,
    required this.userComment,
  });

  final String category;
  final String userComment;
}

final _reportReasons = <NoteReportReason>[
  const NoteReportReason(label: 'スパム・宣伝', value: 'spam'),
  const NoteReportReason(label: 'フィッシング', value: 'phishing'),
  const NoteReportReason(label: '露骨な性的コンテンツ（NSFW含む）', value: 'explicit'),
  const NoteReportReason(label: '個人情報の漏洩', value: 'personalInfoLeak'),
  const NoteReportReason(label: '自傷・自殺をほのめかす投稿', value: 'selfHarm'),
  const NoteReportReason(label: '権利侵害', value: 'violationRights'),
  const NoteReportReason(label: 'その他', value: 'other'),
];

/// ノート通報シートを表示する。
///
/// ユーザーが通報理由を選択して確認する。
/// 確認されれば入力内容を返す、キャンセルされれば null を返す。
Future<NoteReportInput?> showNoteReportSheet(BuildContext context) {
  return showModalBottomSheet<NoteReportInput>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => _NoteReportSheetContent(),
  );
}

class _NoteReportSheetContent extends StatefulWidget {
  @override
  State<_NoteReportSheetContent> createState() =>
      _NoteReportSheetContentState();
}

class _NoteReportSheetContentState extends State<_NoteReportSheetContent> {
  late String selectedCategory = _reportReasons.first.value;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'この投稿を通報する',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Text(
            '通報理由',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: selectedCategory,
            isExpanded: true,
            items: _reportReasons.map((category) {
              return DropdownMenuItem<String>(
                value: category.value,
                child: Text(category.label),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedCategory = value);
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            'コメント（任意）',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: '補足があれば入力してください',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('キャンセル'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  NoteReportInput(
                    category: selectedCategory,
                    userComment: _commentController.text,
                  ),
                ),
                child: const Text('通報する'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
