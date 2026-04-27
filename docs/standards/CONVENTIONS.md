# コーディング規約・命名規則（共通）

このドキュメントでは、`flutter-apps` 配下のアプリで共通利用する命名規則・コーディングスタイルを定義します。

---

## ファイル命名規則

### Model（`models/`）

- モデルは **1ファイル1クラス** を必須とします。
- 関連モデルであっても同居させず、必要な側から import して利用します。

| ファイル名 | クラス名 |
|---|---|
| `note_file.dart` | `NoteFile` |
| `note_file_properties.dart` | `NoteFileProperties` |

### DataSource（`datasources/`）

- ファイル名は **実装種別を先頭** にした `<backend>_<entity>_data_source.dart` 形式を推奨します。
- クラス名も同じ順序（`<Backend><Entity>DataSource`）で合わせます。

| バックエンド | ファイル名 | クラス名 |
|---|---|---|
| Drift（SQLite） | `drift_todo_data_source.dart` | `DriftTodoDataSource` |
| Firestore | `firestore_todo_data_source.dart` | `FirestoreTodoDataSource` |

### Screen（`screens/`）

- 各画面は `screens/<screen_name>/` ディレクトリに格納します。
- 画面のルートWidgetは `StatefulWidget` ではなく `HookWidget` を標準とし、状態管理はProvider（`ChangeNotifier`）で行います。
- ディレクトリ内のファイル構成は以下を標準とします。

| ファイル名 | 役割 |
|---|---|
| `<screen>_screen.dart` | UIウィジェット本体 |
| `<screen>_provider.dart` | 状態管理（ChangeNotifier） |
| `<screen>_screen_state.dart` | 画面状態の定義（freezed） |
| `<screen>_effect_state.dart` | 副作用（SnackBar・遷移など）の定義（freezed、必要な画面のみ） |

### Widget（`widgets/`）

- 再利用可能なウィジェットを格納します。
- ファイル名はウィジェットの役割を表す名前にします（画面名のプレフィックスは不要）。
- 1ファイル1ウィジェットを基本とします。

| ファイル名 | クラス名 | 説明 |
|---|---|---|
| `todo_item.dart` | `TodoItem` | 1件のTodoを表示するアイテム |
| `todo_list.dart` | `TodoList` | Todoの一覧表示 |
| `schedule_notification_input.dart` | `ScheduleNotificationInput` | 通知設定の入力UI |

### Routing（`route/`）

- `go_router` + `go_router_builder` を組み合わせた型安全なルート定義を必須とします。
- 各ルートは `@TypedGoRoute`（必要に応じて `@TypedShellRoute`）を使って定義します。
- 文字列リテラル（`context.go('/xxx')`）による直接遷移は避け、生成された Route API（`const XxxRoute().go(context)`）を使用します。
- `build_runner` で自動生成される `_.g.dart` ファイルにより、mixin と生成ヘルパーが提供されます。

| ファイル名 | 役割 | 例 |
|---|---|---|
| `app_routes.dart` | ルート定義（@TypedGoRoute / @TypedShellRoute および実装） | `@TypedGoRoute<HomeRoute>(path: '/')` |
| `app_routes.g.dart` | 自動生成ファイル。手編集禁止。 | go_router_builder が生成 |

**実装例:**

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';

part 'app_routes.g.dart';

@TypedGoRoute<HomeRoute>(path: '/')
@immutable
class HomeRoute extends GoRouteData with $HomeRoute {
  const HomeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const HomeScreen();
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: $appRoutes,
);
```

### 自動生成ファイル

- `*.g.dart` / `*.freezed.dart` / `di.config.dart` などの自動生成ファイルは **手編集しない**。
- 変更が必要な場合は対応するソースを修正した上で `build_runner` で再生成します。

```sh
# 全体再生成（go_router_builder, injectable, freezed等を含む）
dart run build_runner build --delete-conflicting-outputs

# 特定パッケージのみ再生成（injectable の例）
dart run build_runner build --delete-conflicting-outputs --build-filter="lib/di/di.config.dart"
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

## 運用ルール

- このファイルには全アプリ共通ルールのみ記載します。
- アプリ固有ルールは `apps/<app_name>/docs/README.md` に記載します。
- 例外ルールを追加する場合は、差分ドキュメントに背景と適用範囲を明記します。

## 参考

- [ARCHITECTURE.md](./ARCHITECTURE.md) — レイヤ設計・データフロー・技術選定
- [todo_app 差分](../../apps/todo_app/docs/README.md)
