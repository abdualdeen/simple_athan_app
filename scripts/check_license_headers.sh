#!/bin/sh
set -e
cd "$(dirname "$0")/.."
total=0
missing=0
for f in $(find lib test -name '*.dart'); do
  total=$((total + 1))
  if grep -q "Simply Athan - prayer times and Qibla app." "$f"; then
    :
  else
    missing=$((missing + 1))
    echo "MISSING: $f"
  fi
done
echo "total=$total missing=$missing"
