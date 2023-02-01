#!/bin/sh

# Set destination
dest="$WORKSPACE_PATH/../.."

# Set imported binaries directory
binaries="$dest/Binaries"

# Reset imported binaries
rm -rf "$binaries"
mkdir "$binaries"

# Open versions file
fVersions="$dest/Swift Fixer/Assets.xcassets/Versions.dataset/versions.json"
[ -f $fVersions ] rm $fVersions
versions="[]"

# Copy binaries and note versions
cat "$dest/Swift Fixer/Assets.xcassets/Commands.dataset/commands.json" \
	| /usr/local/bin/jq -r '.[] | .location+"/"+.exec' \
	| while read -r src
do
	cp "$src" "$binaries"
	version=$($src --version)
	versions=$(
		echo $versions | /usr/local/bin/jq -rc \
			--arg exec $(basename $src) \
			--arg version $version \
			'. += [{"exec": $exec, "version": $version}]'
	)
	echo $versions > $fVersions
done
