# コーディング規約・命名規則

このドキュメントでは、todo_app プロジェクト全体で統一する命名規則・コーディングスタイルを定義します。

---

## ファイル命名規則


### DataSource（`datasources/`）

- ファイル名は **実装種別を先頭** にした `<backend>_todo_data_source.dart` 形式で統一します。
- クラス名も同じ順序（`<Backend>TodoDataSource`）で合わせます。

| バックエンド | ファイル名 | クラス名 |
|---|---|---|
| Drift（SQLite） | `drift_todo_data_source.dart` | `DriftTodoDataSource` |
| Firestore | `firestore_todo_data_source.dart` | `FirestoreTodoDataSource` |

### Screen（`screens/`）

- 各画面は `screens/<screen_name>/` ディレクトリに格納します。
- ディレクトリ内のファイル構成は以下の通りです。

| ファイル名 | 役割 |
|---|---|
| `<screen>_screen.dart` | UIウィジェット本体 |
| `<screen>_provider.dart` | 状態管理（ChangeNotifier） |
| `<screen>_screen_state.dart` | 画面状態の定義（freezed） |
| `<screen>_effect_state.dart` | 副作用（SnackBar・遷移など）の定義（freezed、必要な画面のみ） |

例（`add_todo` 画面）:
```
screens/
  add_todo/
    add_todo_screen.dart
    add_todo_provider.dart
    add_todo_screen_state.dart
    add_todo_effect_state.dart
```

### Widget（`widgets/`）

- 再利用可能なウィジェットを格納します。
- ファイル名はウィジェットの役割を表す名前にします（画面名のプレフィックスは不要）。
- 1ファイル1ウィジェットを基本とします。

| ファイル名 | クラス名 | 説明 |
|---|---|---|
| `todo_item.dart` | `TodoItem` | 1件のTodoを表示するアイテム |
| `todo_list.dart` | `TodoList` | Todoの一覧表示 |
| `schedule_notification_input.dart` | `ScheduleNotificationInput` | 通知設定の入力UI |

### 自動生成ファイル

- `*.g.dart` / `*.freezed.dart` / `di.config.dart` などの自動生成ファイルは **手編集しない**。
- 変更が必要な場合は対応するソースを修正した上で `build_runner` で再生成します。

```sh
# injectable（di.config.dart）の再生成
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/di/di.config.dart"

# 全体再生成
dart run build_runner build --delete-conflicting-outputs
```

---

## クラス命名規則

| 種別 | 規則 | 例 |
|---|---|---|
| モデル | `PascalCase` | `Todo`, `ScheduleNotification` |
| DataSource インターフェース | `<Entity>DataSource` | `TodoDataSource` |
| DataSource 実装 | `<Backend><Entity>DataSource` | `DriftTodoDataSource` |
| Repository | `<Entity>Repository` | `TodoRepository` |
| Provider | `<Screen>Provider` | `TodoListProvider` |
| Screen Widget | `<Screen>Screen` | `TodoListScreen` |

---

## 参考

- [ARCHITECTURE.md](./ARCHITECTURE.md) — レイヤ設計・データフロー・技術選定
