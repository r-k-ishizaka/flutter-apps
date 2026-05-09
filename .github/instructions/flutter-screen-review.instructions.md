---
name: "Flutter Screen Diff Review"
description: "Use when reviewing Flutter screen implementation diffs. Check screen/provider naming, folder structure, HookWidget usage, state/effect split, and typed routing compliance in flutter-apps monorepo."
applyTo:
  - "apps/*/lib/screens/**/*.dart"
  - "apps/*/lib/route/**/*.dart"
  - "apps/*/lib/repositories/**/*.dart"
  - "apps/*/lib/datasources/**/*.dart"
---

# Flutter Screen Diff Review Checklist

`flutter-apps` の差分レビュー時は、次を優先して確認する。

1. 命名規則
- Screen は `screens/<screen_name>/<screen_name>_screen.dart`。
- Provider は `<screen_name>_provider.dart` でクラス名は `<ScreenName>Provider`。
- State/Effect は `<screen_name>_screen_state.dart` と `<screen_name>_effect_state.dart`。
- DataSource は `<backend>_<entity>_data_source.dart` / `<Backend><Entity>DataSource`。

2. 構成規約
- 画面本体は `HookWidget` を使用し、`StatefulWidget` を新規導入していない。
- 画面状態は Provider に集約され、UIは状態を監視して描画している。
- 副作用（SnackBar/遷移/ダイアログ）は state 本体から分離されている。
- `widgets/` 配下の再利用Widgetが直接遷移していない。
- Actionsパターンを使う画面では、Screen 側で `useMemoized` により Actions インスタンスを管理している。
- Actionsを毎buildで `XxxActions(...)` 直接生成していない（依存値変更時のみ再生成される）。

3. ルーティング規約
- `go_router_builder` の Typed Route（`@TypedGoRoute`）を使っている。
- 文字列リテラル遷移（`context.go('/xxx')`）を増やしていない。
- 画面入力が多い/条件で分岐する場合、`freezed` の `sealed class`（例: `XxxScreenParam`）で1引数に集約している。
- 集約パラメータは Route の `$extra` で受け渡している（Deep Linkで復元が必要な値は path/query を優先）。

4. 生成ファイル運用
- `*.g.dart` / `*.freezed.dart` / `di.config.dart` を手編集していない。
- 生成が必要な変更では build_runner 実行前提になっている。

5. レビューコメント方針
- 指摘は「重大度」「問題」「修正案」を短く示す。
- 重大度順: `High` -> `Medium` -> `Low`。
- 規約逸脱は可能な限りファイル位置を示して指摘する。
