#!/usr/bin/env bash
# Symlink every folder under this repo's .config into ~/.config.
# Works on macOS and Linux. Safe to re-run.

set -eu

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
SRC="$SCRIPT_DIR/.config"
DEST="${XDG_CONFIG_HOME:-$HOME/.config}"

mkdir -p "$DEST"

for path in "$SRC"/*/; do
	[ -d "$path" ] || continue
	name=$(basename "$path")
	target="$DEST/$name"

	# Never clobber a real (non-symlink) file or directory.
	if [ -e "$target" ] && [ ! -L "$target" ]; then
		echo "skip  $name  (existing non-symlink at $target)"
		continue
	fi

	ln -sfn "$path" "$target"
	echo "link  $name -> $path"
done
