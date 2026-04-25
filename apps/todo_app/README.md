# todo_app

Todoアプリのリファレンス実装です。

## 実装済みの機能

- Todo基本操作（作成・読取・更新・削除）
- ローカルストレージ（Drift/SQLite）とFirestoreのマルチバックエンド対応
- 状態管理（ChangeNotifier + Riverpod基盤）
- 通知スケジューリング

## クイックスタート

```bash
cd /Users/kikuchi/develop/projects/flutter-apps/apps/todo_app
flutter pub get
flutter analyze
flutter test
flutter run
```

## ドキュメント

- アーキテクチャ・レイヤ設計: [`docs/standards/ARCHITECTURE.md`](../../docs/standards/ARCHITECTURE.md)
- 命名規則・コーディング規約: [`docs/standards/CONVENTIONS.md`](../../docs/standards/CONVENTIONS.md)
- todo_app固有ルール: [`docs/README.md`](./docs/README.md)
