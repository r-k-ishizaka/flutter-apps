#!/bin/bash
# lib配下のdartファイルを全てexportするbarrelファイルを自動生成

EXPORT_FILE="$(dirname "$0")/../lib/design_system.dart"
LIB_DIR="$(dirname "$0")/../lib"

echo "// AUTO-GENERATED FILE. DO NOT EDIT." > "$EXPORT_FILE"
echo "" >> "$EXPORT_FILE"

find "$LIB_DIR" -type f -name '*.dart' \
  | grep -v "/design_system.dart$" \
  | sed "s|$LIB_DIR/||" \
  | sort \
  | while read file; do
    echo "export 'package:design_system/$file';" >> "$EXPORT_FILE"
done
