#!/usr/bin/env bash
# Symlink every folder under this repo's .config into ~/.config, and the
# vendored tmux-sessionizer script into ~/.local/bin.
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

# tmux-sessionizer lives in a git submodule (vendor/tmux-sessionizer).
BIN_DIR="${BIN_DIR:-$HOME/.local/bin}"
script="$SCRIPT_DIR/vendor/tmux-sessionizer/tmux-sessionizer"
target="$BIN_DIR/tmux-sessionizer"

git -C "$SCRIPT_DIR" submodule update --init --quiet

if [ -e "$target" ] && [ ! -L "$target" ]; then
	echo "skip  tmux-sessionizer  (existing non-symlink at $target)"
else
	mkdir -p "$BIN_DIR"
	ln -sfn "$script" "$target"
	echo "link  tmux-sessionizer -> $script"
fi

case ":$PATH:" in
	*":$BIN_DIR:"*) ;;
	*) echo "note  $BIN_DIR is not on PATH; add it so tmux-sessionizer is found" ;;
esac
