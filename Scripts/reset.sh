#!/bin/sh

# Set destination
dest="$WORKSPACE_PATH/../.."

# Set imported binaries directory
imported="$dest/Imported"

# Reset imported binaries
rm -rf "$imported"
mkdir "$imported"

# Open versions file
fVersions="$imported/versions.json"
versions="[]"

# Copy binaries and note versions
cat "$dest/Swift Fixer/Assets.xcassets/Commands.dataset/commands.json" | /usr/local/bin/jq -r '.[] | .location+"/"+.exec' | while read -r src
do
	cp "$src" "$imported"
	version=$($src --version)
	versions=$(
		echo $versions | /usr/local/bin/jq -rc \
			--arg exec $(basename $src) \
			--arg version $version \
			'. += [{"exec": $exec, "version": $version}]'
	)
	echo $versions > $fVersions
done
