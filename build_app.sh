#!/bin/bash

mkdir -p Spellbook.app/Contents/MacOS
swift build -c release
cp .build/release/Spellbook Spellbook.app/Contents/MacOS/Spellbook
mkdir -p Spellbook.app/Contents/Resources
cp Info.plist Spellbook.app/Contents/Info.plist
cp icon.icns Spellbook.app/Contents/Resources/icon.icns