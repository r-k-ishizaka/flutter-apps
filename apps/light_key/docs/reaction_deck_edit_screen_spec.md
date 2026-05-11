# ReactionDeckEditScreen 仕様

対象ファイル:
- `apps/light_key/lib/screens/reaction_deck_edit/reaction_deck_edit_screen.dart`
- `apps/light_key/lib/screens/reaction_deck_edit/reaction_deck_edit_provider.dart`
- `apps/light_key/lib/screens/reaction_deck_edit/reaction_deck_edit_screen_state.dart`
- `apps/light_key/lib/route/app_routes.dart`

## 1. 目的

リアクションデッキ（1-4）の名前編集、デッキ内容の並び替え/削除、絵文字追加を1画面で行う。

## 2. 画面遷移

- Typed Route: `ReactionDeckEditRoute`
- パス: `/reaction-decks/:deckId/edit`
- Route引数:
  - `deckId`（`int`）
- Provider初期化時に `initialDeckId` は `1..4` に clamp される。

## 3. 画面構成

- 画面クラス: `ReactionDeckEditScreen`（`HookWidget`）
- タブ:
  - `デッキ内容`
  - `絵文字を追加`
  - `インポート`
- デッキ選択:
  - `SegmentedButton` で `デッキ1` 〜 `デッキ4`
- デッキ名編集:
  - `TextField` + `保存`ボタン
  - Enter送信でも保存
- 保存FAB:
  - `デッキ内容` / `インポート` タブでのみ表示
  - 未保存変更がある場合のみ有効

## 4. データ読み込み

`ReactionDeckEditProvider.load()` で以下を読み込む。
- `getReactionDecks()`（デッキ名）
- `getReactionDeckItems()`（デッキ内絵文字）
- `getEmojisForPicker()`（追加候補）

読み込みルール:
- デッキは必ず 1〜4 を確保（不足時は空で補完）
- デッキ表示件数は最大 32 件（`take(32)`）
- 候補絵文字は `name` 昇順
- 候補カテゴリは `row.category` のトップレベルを使用（`/` 区切りの先頭）

## 5. デッキ内容タブ仕様

### 5.1 表示
- デッキが空の場合: `デッキに絵文字がありません。追加タブから登録してください。`
- 8列グリッドで絵文字を表示
- カスタム絵文字（`:name:`）は URL 解決できる場合 `CustomEmojiCell` で表示

### 5.2 並び替え
- `LongPressDraggable` でドラッグ開始
- ドロップ位置にプレースホルダ表示
- ドロップ時に `reorderEmoji(oldIndex, newIndex)` を実行
- 並び順は Provider の state 更新結果をそのまま描画に反映

### 5.3 削除
- ドラッグ中のみ画面下部に削除ゾーンを表示
- 削除ゾーンへドロップで `removeEmojiAt(index)`

## 6. 絵文字追加タブ仕様

### 6.1 検索
- 検索欄入力で `query` 更新
- 検索中は候補をフラット表示
- 0件時: `一致する絵文字がありません。`

### 6.2 カテゴリ選択
- 非検索時はカテゴリ一覧を表示
- カテゴリ選択後はそのカテゴリの絵文字グリッドを表示
- カテゴリ空時: `このカテゴリに絵文字がありません。`
- 候補全体が空時: `表示できる絵文字がありません。`

### 6.3 追加
- 候補タップで `addEmojiToSelectedDeck(':name:')`
- 登録数表示: `登録数 {現在件数} / 32`

## 7. 保存・未保存管理

### 7.1 未保存フラグ
- デッキごとに `_dirtyDeckIds` を保持
- 以下操作で当該デッキを dirty にする:
  - 追加
  - 削除
  - 並び替え

### 7.2 デッキ内容保存
- `saveSelectedDeck()` で `replaceReactionDeckItems(deckId, emojis)` 実行
- 成功時:
  - dirty解除
  - `hasUnsavedDeckChanges = false`
  - メッセージ `デッキ内容を保存しました。`

### 7.3 デッキ名保存
- `renameSelectedDeck(name)` で `renameReactionDeck(deckId, name)` 実行
- 同名なら何もしない
- 成功時メッセージ: `デッキ名を保存しました。`

## 8. フィードバック表示（SnackBar）

- `state.message` がセットされたら `SnackBar` を表示
- build中呼び出しを避けるため、`addPostFrameCallback` 経由で表示
- 表示後に `clearMessage()` でメッセージを消費
- 新規表示前に `hideCurrentSnackBar()` を呼び、重複表示を抑制

## 9. 戻る操作の仕様

- `PopScope` で戻る動作を制御
- `hasUnsavedDeckChanges == false` のときは通常通り戻る
- `hasUnsavedDeckChanges == true` のとき:
  - AppBar戻る/システム戻る/戻るジェスチャーで確認ダイアログを表示
  - ダイアログ文言:
    - タイトル: `未保存の変更があります`
    - 本文: `変更を破棄して戻りますか？`
    - ボタン: `キャンセル` / `破棄して戻る`
- ダイアログ多重表示防止のため `isBackDialogOpen` を使用

## 10. エラーメッセージ

代表例（Providerで設定）:
- 読み込み失敗: `読み込みに失敗しました: {error}`
- デッキ名保存失敗: `デッキ名の保存に失敗しました: {error}`
- デッキ内容保存失敗: `デッキ内容の保存に失敗しました: {error}`
- 追加上限超過: `1デッキの上限は32件です。`

## 11. 既知の制約

- 1デッキあたり上限32件
- 画面上で追加する候補は `CustomEmojiCell` ベース（`:name:` 形式）
- 絵文字追加時に同一絵文字が既にデッキに含まれる場合は追加せず SnackBar を表示する

## 12. インポートタブ仕様

### 12.1 入力

- 複数行 `TextField` に `:emoji1: :emoji2:` 形式のテキストを貼り付け。
- 入力変更のたびリアルタイムでパース（`:([^:]+):` パターン）。
- ローカル未登録の絵文字・重複は除外。
- 認識件数を入力欄下部に表示。

### 12.2 絵文字グリッド

- 有効な絵文字を8列グリッドで表示。
- **追加済み絵文字**: `primary` 色の枠 + 右上にチェックバッジで強調表示。
- **未追加絵文字**: 通常の `CustomEmojiCell` 表示。
- 空状態:
  - 入力欄が空: `Misskey のリアクションデッキをペーストしてください。`
  - 入力あり・有効絵文字0件: `ローカルに登録された絵文字が見つかりませんでした。`

### 12.3 追加操作

| 状態 | 動作 |
|---|---|
| 未追加 | `addEmojiToSelectedDeck(':name:')` → dirtyフラグ ON |
| 追加済み | SnackBar「`:name:` はすでに追加済みです。」を表示（追加しない） |
| 32件上限 | SnackBar「1デッキの上限は32件です。」を表示 |

### 12.4 保存

- 既存の「デッキ保存」FAB（画面右下）でインポートタブでも保存可能。
- インポートタブでも `hasUnsavedDeckChanges == true` のとき FAB が有効になる。
