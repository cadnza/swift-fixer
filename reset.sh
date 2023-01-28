#!/bin/sh

# Set destination
dest="$WORKSPACE_PATH/../.."

# Set imported binaries directory
imported="$dest/Imported"

# Reset imported binaries
rm -rf "$imported"
mkdir "$imported"

# Copy binaries
cat "$dest/Data/commands.json" | jq -r '.[] | .location+"/"+.title' | while read -r src
do
	cp "$src" "$imported"
done
