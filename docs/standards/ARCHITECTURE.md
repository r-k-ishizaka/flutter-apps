# アーキテクチャ概要（共通）

このドキュメントでは、`flutter-apps` 配下のアプリで共通的に採用するレイヤードアーキテクチャの方針を定義します。

---

## ディレクトリ構成（標準）

```text
lib/
  main.dart                # エントリーポイント
  app.dart                 # アプリ全体の設定（テーマ・Provider）
  route/                   # ルーティング関連（go_router定義など）
    app_routes.dart
    app_routes.g.dart      # go_router自動生成ファイル
  di/                      # 依存性注入関連
    di.dart
    di.config.dart         # injectable自動生成ファイル（手編集しない）
  models/                  # データモデル
  datasources/             # データ取得元（API, DB等）
  repositories/            # リポジトリ層
  screens/                 # 各画面のUI・ロジック
  utils/                   # 定数・ユーティリティ
  widgets/                 # 再利用可能なWidget
```

---

## データフロー

1. **UI（screens/）**
   - ユーザー操作を受け取り、Provider経由で状態を管理
2. **Provider（ChangeNotifier）**
   - 各画面ごとにProvider（ChangeNotifier）を実装し、状態管理とUIへの通知を担当
   - RepositoryをDIで受け取る
3. **Repository（repositories/）**
   - データ取得・保存の窓口。DataSourceに依存
4. **DataSource（datasources/）**
   - 実際のデータ操作（API/DB/ローカル）を担当
   - 命名規則は [CONVENTIONS.md](./CONVENTIONS.md) を参照
5. **モデル（models/）**
   - アプリで扱うデータ構造を定義

```mermaid
flowchart TD
  UI[UI Widget]
  Provider[Provider (ChangeNotifier)]
  Repository[Repository]
  DataSource[DataSource]
  Model[モデル]

  UI --> Provider
  Provider --> Repository
  Repository --> DataSource
  DataSource --> Model
```

## 画面状態管理・UI更新の設計指針

- 各画面は「状態（State）」と「副作用（Effect）」を明確に分離して設計します。
- `screens/` 配下の画面Widgetは `StatefulWidget` を原則使用せず、`HookWidget` と Provider の組み合わせで実装します。
- `sheets/` 配下のUIも同方針とし、画面の状態はProvider、widgetの状態（controllerなど）はhooksで管理します。
- 画面の状態はProvider（ChangeNotifier）で一元管理し、UIはその状態を監視して自動的に再描画されます。
- 画面の状態（例: stable, updating, errorなど）はenumやsealed classで表現し、状態ごとにUIを切り替えます。
- ユーザー操作（入力・ボタン押下など）はProviderのメソッドを通じて状態を更新します。
- データ取得や保存などの非同期処理の結果は、Providerの状態・副作用としてUIに反映されます。
- 副作用（SnackBar表示、画面遷移など）は必要な画面でのみ `effect` プロパティで管理し、UI側から検知して実行します。
- 画面遷移は `screens/` で行い、コンポーネントでは画面遷移処理を行いません。`widgets/` や画面内の表示用コンポーネントは、必要なイベントをコールバックで親の `screen` に通知します。
- 再利用可能なウィジェット（`widgets/`）に複数のアクションを渡す場合は、個別コールバックではなく**Actionsパターン**（インターフェース + 画面固有実装）を採用します。

## 再利用可能なウィジェットとアクション注入パターン

複数の画面で同じウィジェットを使用しながら、画面ごとに異なる振る舞いを実装する場合、**Actionsパターン**を採用します。

### 適用ケース

- 複数のコールバック（5個以上）をウィジェットに渡す必要がある場合
- 同じウィジェットを複数の画面で使用し、画面ごとに異なる処理を実装する場合
- アクション処理に画面固有のProviderやコンテキストが必要な場合

### アーキテクチャ構成

```text
widgets/<widget_name>_actions/
  ├── <widget_name>_actions.dart           # 抽象インターフェース
  ├── default_<widget_name>_actions.dart   # デフォルト実装（何もしない/基本動作）
  └── <widget_name>_actions_mixin.dart     # 共通処理のMixin（任意）

screens/<screen_name>/
  └── <screen_name>_<widget_name>_actions.dart  # 画面固有の実装
```

### 実装手順

1. **インターフェース定義** (`widgets/` 配下)
   - アクションメソッドを抽象メソッドとして定義
   - 必要なパラメータを明示

2. **Mixin 定義** (`widgets/` 配下、任意)
   - 複数の実装で共有されるヘルパーメソッドを提供
   - `BuildContext`へのアクセスを前提とする場合は抽象getterで要求

3. **画面固有実装** (`screens/` 配下)
   - Providerやコンテキストを受け取って実装
   - Mixinを使用して共通処理を継承

4. **Screen での使用**
   - `useMemoized` でActionsインスタンスを作成
   - 依存配列にProviderを含めて適切に再作成

5. **Widget での受け取り**
   - 個別コールバックではなく、Actionsオブジェクトを受け取る
   - `actions?.methodName()` で呼び出し

### コード例

**インターフェース定義:**
```dart
abstract class ItemActions {
  Future<void> onItemTap(Item item);
  Future<void> onEdit(Item item);
  Future<void> onDelete(Item item);
}
```

**Screen での使用:**
```dart
class ListScreen extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListProvider>();
    
    final actions = useMemoized(
      () => ListItemActions(
        provider: provider,
        context: context,
      ),
      [provider],
    );
    
    return ItemList(items: provider.items, actions: actions);
  }
}
```

**Widget での受け取り:**
```dart
class ItemWidget extends HookWidget {
  const ItemWidget({required this.item, this.actions});
  
  final Item item;
  final ItemActions? actions;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: actions != null ? () => actions!.onItemTap(item) : null,
      child: ...,
    );
  }
}
```

### 利点

- **コードの簡素化**: 複数のコールバックを1つのオブジェクトにまとめる
- **再利用性**: 同じウィジェットを異なる画面で異なる動作で使用可能
- **テスタビリティ**: モックActionsを作成してウィジェットテストが容易
- **保守性**: アクション追加時はインターフェースを拡張するだけ

### 注意点

- Actionsオブジェクトは画面のライフサイクルに紐づくため、`useMemoized`で適切に管理する
- `BuildContext`を保持する場合は、使用時に`mounted`チェックを行う
- 単純なコールバック（1〜2個）の場合は、このパターンは過剰設計になる可能性がある

## 技術・設計ポイント

- **状態管理**: Provider（ChangeNotifierProvider）
- **画面実装**: flutter_hooks（`HookWidget` を標準採用）
- **ルーティング**: go_router + go_router_builder（型安全なルート定義）
  - `@TypedGoRoute` アノテーションでルート定義し、`build_runner` で自動生成
  - 詳細は [CONVENTIONS.md](./CONVENTIONS.md) のルーティングセクション参照
- **依存性注入**: get_it + injectable（生成ファイル運用は [CONVENTIONS.md](./CONVENTIONS.md) を参照）
- **モデル生成**: freezed, json_serializable
- **テスト容易性**: DIとレイヤ分離でテストしやすい

---

## 運用ルール

- このファイルには全アプリ共通の原則のみ記載します。
- アプリ固有の例外や追加ルールは `apps/<app_name>/docs/README.md` に記載します。
- 共通原則と差分が矛盾する場合は、差分側に理由と見直しタイミングを明記します。

## 参考

- [CONVENTIONS.md](./CONVENTIONS.md) — 命名規則・コーディングスタイル
- [todo_app 差分](../../apps/todo_app/docs/README.md)
- Flutter公式: https://flutter.dev/
- Provider: https://pub.dev/packages/provider
- go_router: https://pub.dev/packages/go_router
- get_it: https://pub.dev/packages/get_it
- injectable: https://pub.dev/packages/injectable
- freezed: https://pub.dev/packages/freezed
