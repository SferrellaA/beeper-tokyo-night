#!/bin/sh
# Copy the Obsidian theme into the Planner vault. Obsidian reads that folder, not this repo.
set -eu
root=$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)
src="$root/obsidian/Frutiger Aero"
dest="/mnt/c/Users/al/Insync/Planner/.obsidian/themes/Frutiger Aero"
if [ ! -d "$dest" ]; then
  echo "vault theme folder not found: $dest" >&2
  exit 1
fi
# Mirror the folder. cp alone would leave deleted files behind.
find "$dest" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
cp -a "$src/." "$dest/"
echo "synced $src -> $dest"
