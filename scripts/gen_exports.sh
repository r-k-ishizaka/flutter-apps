#!/bin/zsh
# lib配下のdartファイルを全てexportするbarrelファイルを自動生成

PKG_NAME=$1

generate_exports() {
  local PKG_NAME="$1"
  local EXPORT_FILE="packages/$PKG_NAME/lib/$PKG_NAME.dart"
  local LIB_DIR="packages/$PKG_NAME/lib"

  echo "// AUTO-GENERATED FILE. DO NOT EDIT." > "$EXPORT_FILE"
  echo "" >> "$EXPORT_FILE"

  find "$LIB_DIR" -type f -name '*.dart' \
    | grep -v "/$PKG_NAME.dart$" \
    | sed "s|$LIB_DIR/||" \
    | sort \
    | while read file; do
      echo "export 'package:$PKG_NAME/$file';" >> "$EXPORT_FILE"
    done
  echo "Generated: $EXPORT_FILE"
}

if [ -z "$PKG_NAME" ] || [[ "$PKG_NAME" == "{{args}}" ]]; then
  for dir in packages/*/; do
    pkg=$(basename "$dir")
    # libディレクトリが存在するパッケージのみ対象
    if [ -d "packages/$pkg/lib" ]; then
      generate_exports "$pkg"
    fi
  done
else
  generate_exports "$PKG_NAME"
fi
