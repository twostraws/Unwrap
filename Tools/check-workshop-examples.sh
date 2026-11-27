#!/bin/sh
set -eu

cd "$(dirname "$0")/.."
examples=Unwrap/Activities/Learn/Workshop
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
sdk=$(xcrun --sdk iphonesimulator --show-sdk-path)

for name in BadgeState BadgeStorage BadgeLoading; do
    cp "$examples/$name.txt" "$scratch/ContentView.swift"
    xcrun swiftc -typecheck -warnings-as-errors -swift-version 6 \
        -sdk "$sdk" -target arm64-apple-ios27.0-simulator "$scratch/ContentView.swift"
done

mkdir -p "$scratch/Tests/BadgeChecks"
cp "$examples/BadgeChecks.txt" "$scratch/Tests/BadgeChecks/BadgeChecks.swift"
cat >"$scratch/Package.swift" <<'SWIFT'
// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "WorkshopExamples",
    platforms: [.macOS(.v15)],
    targets: [.testTarget(name: "BadgeChecks")]
)
SWIFT
swift test --package-path "$scratch"
