---
name: flutter-screen-implementation
description: "Flutterの画面実装ワークフロー。HookWidget + Provider(ChangeNotifier) + go_router + injectable + freezed前提で、設計から実装・生成・検証までを一貫して進める。新規画面追加、既存画面改修、state/effect分離が必要なときに使う。"
argument-hint: "実装したい画面名と要件（状態・副作用・遷移・データ入出力）を指定"
user-invocable: true
disable-model-invocation: false
---

# Flutter Screen Implementation

`flutter-apps` モノレポの共通規約に沿って、画面実装を迷いなく進めるためのスキルです。

## いつ使うか

- 新しい画面を追加するとき
- 既存画面を HookWidget + Provider 構成へ寄せるとき
- 状態（State）と副作用（Effect）を分離して設計したいとき
- go_router の型安全ルートに沿って遷移を実装したいとき

## 必要入力

- 対象アプリ名（例: `todo_app`, `light_key`）
- 画面名（英語スネークケース推奨）
- 画面要件
  - 表示する情報
  - ユーザー操作
  - 非同期処理（取得・保存）
  - 副作用（SnackBar、遷移、ダイアログ等）

## 手順

1. 要件と適用ルールを確認する。
   - まず共通ルールを読む: [Architecture](../../../docs/standards/ARCHITECTURE.md)
   - 命名・構成を確認する: [Conventions](../../../docs/standards/CONVENTIONS.md)
   - 対象アプリ差分ルールがある場合は優先して確認する（例: `apps/<app_name>/docs/README.md`）。

2. 画面フォルダとファイル構成を決める。
   - 標準構成: `screens/<screen_name>/`
   - 作成対象:
     - `<screen_name>_screen.dart`
     - `<screen_name>_provider.dart`
     - `<screen_name>_screen_state.dart`
     - `<screen_name>_effect_state.dart`（副作用がある場合のみ）
    - まず雛形 assets をコピーしてプレースホルダを置換する。
       - [screen template](./assets/screen_template.dart.txt)
       - [provider template](./assets/provider_template.dart.txt)
       - [screen state template](./assets/screen_state_template.dart.txt)
       - [effect state template](./assets/effect_state_template.dart.txt)

3. State と Effect を設計する。
   - 画面状態は enum または sealed class/freezed で明示する。
   - 読み込み中、成功、空、エラーを判別可能にする。
   - 副作用が必要な場合のみ effect を追加する。

4. Provider（ChangeNotifier）を実装する。
   - Repository を DI で受け取る。
   - UIに見せる状態は getter で公開する。
   - 非同期処理は「開始 -> 成功/失敗」の状態遷移を明示する。
   - Effect を使う場合は「発火」と「消費後クリア」の両方を実装する。

5. Screen（HookWidget）を実装する。
   - `StatefulWidget` は使わない。
   - Provider の状態を監視してUIを切り替える。
   - Effect を監視して一度だけ副作用を実行する。
   - 画面遷移は screen 側で行う。
   - `widgets/` 配下の再利用Widgetでは遷移を持たせず、コールバックで通知する。

6. ルーティングを追加する。
   - `@TypedGoRoute` を使ってルートを定義する。
   - 文字列リテラル遷移（`context.go('/xxx')`）は避け、生成 Route API を使う。

7. データ層の追加が必要なら更新する。
   - 新しいデータ操作が必要な場合のみ DataSource/Repository を拡張する。
   - 命名は `<backend>_<entity>_data_source.dart` / `<Backend><Entity>DataSource` を守る。

8. 自動生成を実行する。

```sh
dart run build_runner build --delete-conflicting-outputs
```

9. 品質確認を行う。
   - `dart analyze` が通る
   - 影響範囲のテスト（provider/screen/repository）を追加または更新
   - 生成ファイルを手編集していないことを確認

## 分岐ルール

- 副作用が不要:
  - `<screen_name>_effect_state.dart` は作らない
  - Provider は純粋な状態管理に限定
- 副作用が必要:
  - effect を型で定義する
  - UI側で effect を購読し、実行後にクリアする
- 永続化・外部連携が不要:
  - Repository/DataSource の変更はしない
- 永続化・外部連携が必要:
  - Repository/DataSource を追加し、Provider から呼ぶ

## 完了チェック

- 画面は `HookWidget` で実装されている
- 状態は Provider に集約され、UI が状態に従って再描画される
- 副作用は state から分離されている（必要時のみ）
- ルーティングは Typed Route API を利用している
- 命名規則・ファイル構成が共通規約に準拠している
- build_runner 生成物が最新である

## 実行時テンプレート

次の形式で依頼を受けたら、この手順を適用する。

```text
アプリ: <app_name>
画面名: <screen_name>
要件:
- 表示:
- 操作:
- 非同期処理:
- 副作用:
```

## Assets の置換ルール

- `__SCREEN_NAME__`: 画面のスネークケース名（例: `task_list`）
- `__ScreenName__`: 画面のパスカルケース名（例: `TaskList`）
- effect が不要な場合:
   - `__SCREEN_NAME___effect_state.dart` を作らない
   - screen/provider から effect import と関連コードを削除する
