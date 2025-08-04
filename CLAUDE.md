# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Spellbook is a macOS menu bar application built with Swift and SwiftUI that provides quick access to text prompts. The app displays as a status bar item with a hierarchical menu system for organizing and managing prompts in folders.

## Build and Development Commands

### Building the Application
```bash
# Build the release version
swift build -c release

# Build and package the complete .app bundle
./build_app.sh
```

### Development Commands
```bash
# Build for development/debugging
swift build

# Run the application directly (development mode)
swift run
```

## Architecture Overview

### Core Components

**Data Models** (`Sources/Spellbook/`):
- `Node.swift`: Enum representing either a Prompt or Folder in the hierarchy
- `Prompt.swift`: Structure containing prompt name and content with UUID identification
- `Folder.swift`: Structure containing folder name and array of child nodes
- `PromptStore.swift`: Handles JSON persistence to ~/Documents/prompts.data

**Application Structure**:
- `SpellbookApp.swift`: Main SwiftUI app entry point with NSApplicationDelegateAdaptor
- `AppDelegate.swift`: Core application logic managing NSStatusItem and menu construction

### Key Architecture Patterns

1. **Status Bar Integration**: Uses NSStatusItem to create native macOS menu bar presence
2. **Hierarchical Data Structure**: Recursive Node enum allows unlimited nesting of folders/prompts
3. **Clipboard Integration**: Direct NSPasteboard interaction for copying prompts and creating new ones
4. **Persistent Storage**: JSON-based storage in user Documents directory
5. **Modal Interaction**: Keyboard modifiers (Cmd/Shift) change menu item behavior

### Menu Interaction Logic
- **Normal Click**: Copy prompt content to clipboard
- **Cmd+Click**: Delete prompt/folder (when unlocked) - shows 🗑 icon during cmd press
- **Shift+Click**: Replace prompt content with clipboard (when unlocked) - shows ✏️ icon during shift press
- **Lock State**: Toggles edit functionality on/off and disables visual indicators
- **Menu Ordering**: Folders displayed first (alphabetically), then prompts (alphabetically)

### File Structure
```
Sources/Spellbook/
├── SpellbookApp.swift      # SwiftUI app definition
├── AppDelegate.swift      # Main application logic and menu management
├── Node.swift             # Hierarchical data structure enum
├── Prompt.swift           # Prompt data model
├── Folder.swift           # Folder data model
└── PromptStore.swift      # JSON persistence layer
```

## Platform Requirements

- macOS 12.0+ (specified in Package.swift)
- Swift 5.5+ toolchain
- No external dependencies

## Data Storage

User data is stored as JSON in `~/Documents/prompts.data` using Swift's Codable protocol for serialization.