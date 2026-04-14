#!/bin/zsh
# lib配下のdartファイルを全てexportするbarrelファイルを自動生成

PKG_NAME="design_system"
EXPORT_FILE="packages/$PKG_NAME/lib/$PKG_NAME.dart"
LIB_DIR="packages/$PKG_NAME/lib"

echo "// AUTO-GENERATED FILE. DO NOT EDIT." > "$EXPORT_FILE"
echo "" >> "$EXPORT_FILE"

find "$LIB_DIR" -type f -name '*.dart' \
  | grep -v "/$PKG_NAME.dart$" \
  | sed "s|$LIB_DIR/||" \
  | sort \
  | while read file; do
    echo "export 'package:$PKG_NAME/$file';" >> "$EXPORT_FILE"
done
