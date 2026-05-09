# NoteActions アーキテクチャ

## 概要

`NoteActions` は、ノートに対するユーザーアクション（タップ、リアクション、リノートなど）を抽象化したインターフェースです。
複数の画面（Timeline、Profile、NoteDetail、Notificationsなど）で共通のノート表示ウィジェット（`TimelineNoteItem`）を使用する際に、
画面ごとに異なるアクション処理を注入できるようにします。

## ディレクトリ構成

```
lib/widgets/note_actions/
├── note_actions.dart              # 抽象インターフェース
├── default_note_actions.dart      # デフォルト実装（何もしない）
└── note_actions_mixin.dart        # 共通処理のMixin
```

各画面固有の実装:
```
lib/screens/
├── timeline/
│   └── timeline_note_actions.dart
├── profile/
│   └── profile_note_actions.dart
├── note_detail/
│   └── note_detail_note_actions.dart
└── notifications/
    └── notifications_note_actions.dart
```

## 使用方法

### 1. 画面での使用例

```dart
class TimelineScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TimelineProvider>();
    
    // アクションをuseMemoizedで作成
    final actions = useMemoized(
      () => TimelineNoteActions(
        provider: provider,
        context: context,
      ),
      [provider],
    );
    
    return TimelineList(
      notes: provider.state.notes,
      actions: actions,  // ← 1つのオブジェクトで渡す
    );
  }
}
```

### 2. WidgetでのAction受け取り

```dart
class TimelineNoteItem extends HookWidget {
  const TimelineNoteItem({
    required this.note,
    this.actions,  // ← NoteActionsを受け取る
  });

  final Note note;
  final NoteActions? actions;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: actions != null ? () => actions!.onNoteTap(note) : null,
      child: Column(
        children: [
          IconButton(
            onPressed: actions != null ? () => actions!.onReply(note) : null,
            icon: Icon(Icons.reply),
          ),
        ],
      ),
    );
  }
}
```

### 3. 画面固有の実装

```dart
class TimelineNoteActions with NoteActionsMixin implements NoteActions {
  TimelineNoteActions({
    required this.provider,
    required BuildContext context,
  }) : _context = context;

  final TimelineProvider provider;
  final BuildContext _context;

  @override
  BuildContext get context => _context;

  @override
  Future<void> onReaction(Note note) async {
    final emoji = await pickReaction();  // Mixinのヘルパーメソッド
    if (emoji == null || !context.mounted) return;
    
    final message = await provider.createReaction(note, emoji);
    if (!context.mounted || message == null) return;
    showSnackBar(message);  // Mixinのヘルパーメソッド
  }
  
  // ...その他のメソッド実装
}
```

## 利点

### 1. コードの簡素化
- **以前**: 8〜10個のコールバックを個別に渡していた
- **現在**: 1つの`actions`オブジェクトで統一

```dart
// 以前
TimelineNoteItem(
  onTap: () => ...,
  onReply: () => ...,
  onRenote: () => ...,
  onReaction: () => ...,
  onReactionChipTap: (reaction) => ...,
  onUserTap: (user) => ...,
  onBodyEmojiTap: (emoji) => ...,
  onReplyNoteTap: (reply) => ...,
)

// 現在
TimelineNoteItem(
  actions: timelineActions,
)
```

### 2. 再利用性の向上
- 複数の画面で同じウィジェットを使用しながら、画面ごとに異なる動作を実装できる
- 画面固有の要件（例: Profileでは自ユーザータップ無効）を簡単に実現

### 3. テスタビリティ
- モックActionsオブジェクトを作成してウィジェットテストが容易に
- 各画面のActionsクラスを個別にテスト可能

### 4. 保守性
- アクション追加時はインターフェースを拡張するだけ
- 各画面の実装は独立しており、影響範囲が限定的

## NoteActionsMixin

共通処理を提供するMixin。以下のヘルパーメソッドを含む:

- `showSnackBar(message)` - SnackBarの表示
- `showComingSoon(label)` - 準備中メッセージの表示
- `pickReaction()` - リアクションピッカーの表示
- `pickRenoteAction()` - リノートアクションシートの表示
- `pickEmojiAction(emoji)` - 絵文字アクションシートの表示
- `copyEmojiToClipboard(emoji)` - 絵文字のクリップボードコピー
- `getNoteDetailId(note)` - ノート詳細表示用IDの取得
- `getReplyTargetId(note)` - リプライ対象IDの取得
- `getReplyTargetNote(note)` - リプライ対象ノートの取得
- `getReplyPreviewText(note)` - リプライプレビューテキストの取得

## 各画面の実装方針

| 画面 | ノート詳細遷移 | ユーザー遷移 | リプライ | リノート | リアクション | 絵文字操作 | 返信元/引用タップ遷移 | 制限・補足 |
|------|----------------|--------------|----------|----------|--------------|------------|------------------------|-------------|
| Timeline | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 引用リノートは未実装 |
| Profile | ✅ | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ユーザータップは表示中プロフィールと異なる場合のみ遷移。引用リノートは未実装 |
| NoteDetail | ⚠️ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | 本体ノートタップは無効（表示中のため）。引用リノートは未実装 |
| Notifications | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | Reply/Mention/Quote など `TimelineNoteItem` を使う通知種別で利用可能。引用リノートは未実装 |

- ✅: 実装済み
- ⚠️: 条件付きで実装
- ❌: 未実装

## テスト

テスト用のモックActionsクラス例:

```dart
class MockNoteActions implements NoteActions {
  Note? lastTappedNote;
  String? lastTappedReaction;
  
  @override
  Future<void> onReactionChipTap(Note note, String reaction) async {
    lastTappedNote = note;
    lastTappedReaction = reaction;
  }
  
  // その他のメソッドは空実装
}

// テストでの使用
final mockActions = MockNoteActions();
await tester.pumpWidget(
  TimelineNoteItem(note: testNote, actions: mockActions),
);
await tester.tap(find.byKey(Key('reaction-chip-👍')));
expect(mockActions.lastTappedReaction, '👍');
```

## 移行ガイド

既存コードから新しいActionsベースのアーキテクチャへの移行:

1. 画面固有の`*_note_actions.dart`を作成
2. `NoteActionsMixin`を使用して実装
3. 画面のbuildメソッドで`useMemoized`を使ってActionsインスタンスを作成
4. ウィジェットに`actions:`パラメータを渡す
5. 個別のコールバックパラメータを削除

## アーキテクチャ規約への準拠

このアーキテクチャは `flutter-apps` の以下の規約に準拠:

- ✅ `widgets/`配下のWidgetは直接遷移せず、コールバック(Actions)で通知
- ✅ 画面状態はProviderに集約、UIは状態を監視
- ✅ 副作用（SnackBar/遷移）は画面(Screen)またはActions側で実行
- ✅ `HookWidget`を使用し、`StatefulWidget`は使用しない
