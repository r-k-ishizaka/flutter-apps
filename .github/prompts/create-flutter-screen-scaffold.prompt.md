---
name: "Create Flutter Screen Scaffold"
description: "Flutter画面の雛形を4ファイルで自動生成する。HookWidget + Provider + ScreenState + EffectState の構成で screens/<name>/ を作成したいときに使う。"
argument-hint: "app_name と screen_name を指定。例: app=todo_app screen=task_list"
agent: "agent"
---

引数（または本文）から `app_name` と `screen_name` を読み取り、`apps/<app_name>/lib/screens/<screen_name>/` に以下4ファイルを生成してください。

- `<screen_name>_screen.dart`
- `<screen_name>_provider.dart`
- `<screen_name>_screen_state.dart`
- `<screen_name>_effect_state.dart`

雛形は次の assets をベースにしてください。

- [screen template](../skills/flutter-screen-implementation/assets/screen_template.dart.txt)
- [provider template](../skills/flutter-screen-implementation/assets/provider_template.dart.txt)
- [screen state template](../skills/flutter-screen-implementation/assets/screen_state_template.dart.txt)
- [effect state template](../skills/flutter-screen-implementation/assets/effect_state_template.dart.txt)

プレースホルダ置換:

- `__SCREEN_NAME__` -> 画面名スネークケース
- `__ScreenName__` -> 画面名パスカルケース

要件:

1. 既存規約に従う。
   - `docs/standards/ARCHITECTURE.md`
   - `docs/standards/CONVENTIONS.md`
2. 画面Widgetは `HookWidget` を使う。
3. Providerは `ChangeNotifier` を使い、状態を公開する。
4. ScreenState と EffectState は `freezed` で定義する前提の雛形にする。
5. 実装は最小限でもコンパイルしやすい骨格にする。
6. 生成後、必要なら `dart run build_runner build --delete-conflicting-outputs` が必要な旨を案内する。

出力ルール:

- まず「作成したファイル一覧」を示す。
- 次に、各ファイルの役割を1行ずつ説明する。
- 既存構成との差分がある場合は最後に理由を書く。
