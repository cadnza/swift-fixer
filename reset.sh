#!/bin/sh

# Set destination
dest="$WORKSPACE_PATH/../.."

# Remove binaries and files
rm -rf "$dest/swift-format"
rm -rf "$dest/swiftlint"
rm "$dest/.swift-format"
rm "$dest/.swiftlint.yml"

# Copy binaries and files
cp /usr/local/bin/swift-format "$dest"
cp /usr/local/bin/swiftlint "$dest"
cp /Users/cadnza/Repos/shDotFiles/.swift-format "$dest"
cp /Users/cadnza/Repos/shDotFiles/.swiftlint.yml "$dest"
