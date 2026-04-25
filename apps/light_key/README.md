# light_key

Misskey向け軽量クライアントのサンプル実装です。

## 実装済みの最小機能

- 認証・認可（`/api/i` でアクセストークン検証）
- タイムライン取得（`/api/notes/timeline`）
- 投稿（`/api/notes/create`）


## クイックスタート

```bash
cd /Users/kikuchi/develop/projects/flutter-apps/apps/light_key
flutter pub get
flutter analyze
flutter test
flutter run
```

## 使い方

1. 認証画面で `Misskey サーバーURL` と `アクセストークン` を入力
2. `ログインして検証` を押下
3. タイムライン画面で取得、投稿画面で投稿

## ドキュメント

- アーキテクチャ・レイヤ設計: [`docs/standards/ARCHITECTURE.md`](../../docs/standards/ARCHITECTURE.md)
- 命名規則・コーディング規約: [`docs/standards/CONVENTIONS.md`](../../docs/standards/CONVENTIONS.md)
