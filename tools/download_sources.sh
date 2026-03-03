#!/usr/bin/env bash
# download_sources.sh — Downloads Tanzil XML sources into tools/input/
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT_DIR="$SCRIPT_DIR/input"
mkdir -p "$INPUT_DIR"

BASE_URL="https://tanzil.net/pub/download"

declare -A FILES=(
  ["quran-uthmani.xml"]="$BASE_URL/quran-uthmani.xml"
  ["quran-data.xml"]="$BASE_URL/quran-data.xml"
  ["tr.elmalili.xml"]="$BASE_URL/trans/tr.yazir"
  ["tr.transliteration.xml"]="$BASE_URL/trans/en.transliteration"
)

echo "=== SÜKÛN: Downloading Tanzil sources ==="
echo ""

for filename in "${!FILES[@]}"; do
  url="${FILES[$filename]}"
  dest="$INPUT_DIR/$filename"
  echo "Downloading $filename ..."
  echo "  URL:  $url"
  echo "  Dest: $dest"
  curl -L --fail --silent --show-error -o "$dest" "$url"
  echo "  Done ($(wc -c < "$dest") bytes)"
  echo ""
done

echo "=== All files saved to $INPUT_DIR ==="
ls -lh "$INPUT_DIR"
