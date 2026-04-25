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
- 画面の状態はProvider（ChangeNotifier）で一元管理し、UIはその状態を監視して自動的に再描画されます。
- 画面の状態（例: stable, updating, errorなど）はenumやsealed classで表現し、状態ごとにUIを切り替えます。
- ユーザー操作（入力・ボタン押下など）はProviderのメソッドを通じて状態を更新します。
- データ取得や保存などの非同期処理の結果は、Providerの状態・副作用としてUIに反映されます。
- 副作用（SnackBar表示、画面遷移など）は必要な画面でのみ `effect` プロパティで管理し、UI側から検知して実行します。

## 技術・設計ポイント

- **状態管理**: Provider（ChangeNotifierProvider）
- **ルーティング**: go_router
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
