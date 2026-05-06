#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"

cd "$ROOT_DIR"

collect_changed_paths() {
  git status --porcelain | awk '{print substr($0,4)}' | sed 's|^"||; s|"$||' | awk -F" -> " '{print $NF}' || true
}

find_package_root() {
  local rel="$1"
  local dir

  dir="$(dirname "$rel")"
  while [[ "$dir" != "." && "$dir" != "/" ]]; do
    if [[ -f "$ROOT_DIR/$dir/pubspec.yaml" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done

  return 1
}

changed_paths=()
while IFS= read -r line; do
  changed_paths+=("$line")
done < <(collect_changed_paths)

if [[ ${#changed_paths[@]} -eq 0 ]]; then
  echo "[hook] No changed files. Skip validation."
  exit 0
fi

package_roots=()

add_unique_package_root() {
  local candidate="$1"
  local existing
  for existing in "${package_roots[@]}"; do
    if [[ "$existing" == "$candidate" ]]; then
      return 0
    fi
  done
  package_roots+=("$candidate")
}

for rel in "${changed_paths[@]}"; do
  [[ -z "$rel" ]] && continue
  [[ "$rel" != *.dart ]] && continue
  [[ "$rel" == *.g.dart ]] && continue
  [[ "$rel" == *.freezed.dart ]] && continue

  if root="$(find_package_root "$rel")"; then
    add_unique_package_root "$root"
  fi
done

if [[ ${#package_roots[@]} -eq 0 ]]; then
  echo "[hook] No relevant Dart source changes. Skip validation."
  exit 0
fi

for root in "${package_roots[@]}"; do
  echo "[hook] Validate package: $root"

  pushd "$ROOT_DIR/$root" >/dev/null

  if grep -q "build_runner:" pubspec.yaml; then
    echo "[hook] Running build_runner in $root"
    dart run build_runner build --delete-conflicting-outputs
  else
    echo "[hook] build_runner not configured in $root. Skip build generation."
  fi

  echo "[hook] Running dart analyze in $root"
  dart analyze

  popd >/dev/null
done

echo "[hook] Validation completed."
