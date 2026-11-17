#!/bin/sh
# Adds the GPLv3 copyright header to every Dart source file in lib/ and test/.
# Idempotent: files that already contain the header are skipped.
set -e
cd "$(dirname "$0")/.."

HEADER_FILE=/tmp/gpl_header.txt
cat > $HEADER_FILE << 'EOF'
// Simply Athan - prayer times and Qibla app.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.

EOF

added=0
skipped=0
for file in lib/*.dart lib/*/*.dart test/*.dart; do
  if [ ! -f "$file" ]; then
    continue
  fi
  if grep -q "Simply Athan - prayer times and Qibla app." "$file"; then
    skipped=$((skipped + 1))
    continue
  fi
  cat "$HEADER_FILE" "$file" > "$file.tmp" && mv "$file.tmp" "$file"
  added=$((added + 1))
done

echo "header added to $added file(s), $skipped already had one"
