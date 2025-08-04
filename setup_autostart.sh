#!/bin/bash

# Setup script to make Spellbook launch on login

APP_PATH="/Applications/Spellbook.app"
PLIST_NAME="com.spellbook.app.plist"
USER_AGENTS_DIR="$HOME/Library/LaunchAgents"

echo "Setting up Spellbook to launch on login..."

# Create LaunchAgents directory if it doesn't exist
mkdir -p "$USER_AGENTS_DIR"

# Create the launch agent plist
cat > "$USER_AGENTS_DIR/$PLIST_NAME" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.spellbook.app</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/open</string>
        <string>$APP_PATH</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <false/>
</dict>
</plist>
EOF

# Load the launch agent
launchctl load "$USER_AGENTS_DIR/$PLIST_NAME"

echo "✅ Spellbook is now set to launch automatically on login!"
echo ""
echo "To disable auto-launch later, run:"
echo "launchctl unload ~/Library/LaunchAgents/$PLIST_NAME"
echo "rm ~/Library/LaunchAgents/$PLIST_NAME"