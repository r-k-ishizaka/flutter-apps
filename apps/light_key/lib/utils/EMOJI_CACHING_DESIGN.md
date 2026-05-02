
# 絵文字キャッシュ データフロー

## 目的

Misskey の各 API レスポンスに含まれるカスタム絵文字を、
`Interceptor` で抽出して `DataSource` にヒントとして付与し、
`Repository` でサイズキャッシュを実行する。

最終的に UI では `EmojiText` が `EmojiCache` を参照してインライン描画する。

---

## レイヤ責務

- `EmojiCachingInterceptor`
  - レスポンス JSON から絵文字を抽出
  - `response.extra['emojisToCache']` にヒントを付与
  - **キャッシュ実行はしない**

- `MisskeyHttpClient`
  - `response.extra` を読み取り
  - `ResponseWithCacheHints<T>` (`data` + `emojisToCache`) を返却

- `DataSource`
  - `ResponseWithCacheHints<T>` を生成して返す

- `Repository`
  - `ResponseWithCacheHints<T>.emojisToCache` を受け取り
  - `EmojiRepository.cacheEmojiHints(...)` で DB + `EmojiCache` を更新
  - 呼び出し元には通常の `Result<T>` を返す

- `Provider`
  - `Repository` の `Result<T>` を画面状態へ反映
  - `app.dart` で `Provider<EmojiCache>` を提供

- `Screen`
  - `context.read<EmojiCache>()` で `EmojiCache` を受け取る
  - 子 Widget へ constructor injection で渡す

- `Widget`
  - `emojiCache` をコンストラクタで受け取る
  - `EmojiText` / `TimelineNoteItem` / `RenoteCard` / `NoteReactionList` などの表示専用コンポーネントとして利用する

- `EmojiText`
  - コンストラクタで受け取った `emojiCache` からエントリを参照
  - `:shortcode:` / `:shortcode@host:` を画像化

---

## 主要フロー（読み取り系）

### 1) Timeline (`/api/notes/timeline`)

1. `MisskeyHttpClient` が API 応答を受信
2. `EmojiCachingInterceptor` が `emojis/reactionEmojis/reactions` から抽出し `extra['emojisToCache']` に付与
3. `MisskeyHttpClient.postJsonListWithCacheHints` が `ResponseWithCacheHints<List<Map>>` を返す
4. `MisskeyTimelineDataSource.fetchTimeline` が `ResponseWithCacheHints<List<Note>>` を返す
5. `TimelineRepository.fetchTimeline` が `emojisToCache` を `EmojiRepository.cacheEmojiHints` に委譲
6. `TimelineProvider.fetch` が `Result<List<Note>>` を状態に反映
7. `TimelineScreen` が `Provider<EmojiCache>` から `EmojiCache` を受け取って `TimelineList` に渡す
8. `TimelineList` → `TimelineNoteItem` → `EmojiText` / `RenoteCard` / `NoteReactionList` が constructor injection で `emojiCache` を受け取って描画する

### 2) Note 詳細 (`/api/notes/show`)

1. `MisskeyTimelineDataSource.fetchNote` が `ResponseWithCacheHints<Note>` を返す
2. `TimelineRepository.parseStreamEvent` 内の補完取得時に `emojisToCache` をキャッシュ
3. `TimelineScreen` 配下の `TimelineNoteItem` / `EmojiText` が screen から渡された `emojiCache` を使って描画する

### 3) User Profile (`/api/users/show`, `/api/users/notes`)

1. `MisskeyUserProfileDataSource.fetchUserProfile/fetchUserNotes` が `ResponseWithCacheHints<T>` を返す
2. `UserProfileRepository` が `emojisToCache` をキャッシュ
3. `ProfileProvider` が状態更新
4. `ProfileScreen` が `Provider<EmojiCache>` から `EmojiCache` を受け取り、`_ProfileSummary` / `_ProfileNotesSliver` / `TimelineNoteItem` に渡す
5. `EmojiText` が constructor injection された `emojiCache` を参照して描画

### 4) Auth Verify (`/api/i`)

1. `MisskeyAuthDataSource.verify` が `ResponseWithCacheHints<User>` を返す
2. `AuthRepository.signInWithOAuth` が `emojisToCache` をキャッシュ
3. `AuthProvider` が認証状態を更新

### 5) Post Create (`/api/notes/create`)

1. `MisskeyPostDataSource.createPost` が `ResponseWithCacheHints<Map<String, dynamic>>` を返す
2. `PostRepository.createPost` が `emojisToCache` をキャッシュ
3. `PostProvider.submit` が投稿結果を状態反映
4. `PostScreen` のプレビュー `TimelineNoteItem` も screen から渡された `emojiCache` を使って描画

---

## 描画フロー (`EmojiText`)

1. `Screen` が `Provider<EmojiCache>` から `EmojiCache` を受け取り、必要な子 Widget に constructor injection で渡す
2. `EmojiText` がテキストから `:shortcode:` を検出
3. `EmojiCache.getEntry(name)` で URL/サイズを取得
4. サイズ情報 (`aspectRatio`) から表示幅を計算
5. `CachedNetworkImage` でインライン表示
6. 未キャッシュなら `:shortcode:` をテキストのまま表示

---

## 命名ルール

- レスポンスラッパー: `ResponseWithCacheHints<T>`
- 絵文字ヒント配列: `emojisToCache`
- ヒント要素: `EmojiToCache { name, url }`

この命名により「Interceptor はヒント付与のみ」「Repository が実キャッシュ実行」という責務が明確になる。
