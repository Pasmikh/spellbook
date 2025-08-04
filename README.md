# Spellbook

macOS menu bar app for quick access to text prompts.

<video width="600" autoplay muted loop>
  <source src="https://github.com/pasmikh/spellbook/releases/download/v1.0/spellbook_video.mov" type="video/mp4">
  Your browser does not support the video tag.
</video>

## How to Use

- **Copy**: Click any prompt to copy to clipboard.
- **Add** First line from clipboard becomes prompt name, other lines become content.
- **Replace**: Shift+click prompt to replace with clipboard content (✏️ appears when unlocked).
- **Delete**: Cmd+click prompt/folder to delete
- **Lock**: Click lock button to disable editing. Click unlock to enable editing.
- **Storage**: Prompts saved to `~/Documents/prompts.data`

## Install

```bash
./build_app.sh
mv Spellbook.app /Applications/
```

## How to Vibe/Code

I suggest you write your own version to fit your taste.
My original prompt for building with Claude Code or Gemini CLI:

```
I want to write an app using gemini cli to display an icon on top of my macbook screen. Upon hovering, list of prompt headings should get displayed. When I click it, prompt gets copied to my buffer.

Interface should look exactly like native mac menus that are displayed on the left side of mac top bar, menus like "File", "Edit", etc.

## Functionality

### Prompt management
- Copy Prompt: When I click on the prompt name, it gets copied to my buffer.
- Delete Prompt: When I cmd+click on the prompt name, it gets deleted. While cmd is pressed, small "bin" icon is displayed next to each item in menu. App window does not close after deleting a prompt.
- Replace Prompt: When I shift+click on the prompt name, it gets replaced with content of my clipboard. While shift is pressed, small "pencil" icon is displayed next to each item in menu. When replacing the prompt, all clibpoard content gets inserted into prompt content, prompt name (displayed in UI) stays the same. App window does not close after replacing prompt.
- Add Prompt: There is "Add Prompt" button that creates new prompt. Prompt name (displayed in UI) is first line of clipboard, content of the prompt is everything else from clipboard.

### Folder management
- Add Folder: There is "Add Folder" button that creates new folder. It's name is set up in pop up window with text input.
- Show Folder: Folders upon hovering show their submenu with prompts
- Delete Folder: Upon cmd+click on folder, it gets deleted with all content. While cmd is pressed, small "bin" icon is displayed next to each item in menu. App window does not close after deleting a folder.
- Nested buttons: Each folder has "Add Prompt" button that adds prompt to that folder. Each folder has "Add folder" button that adds new folder into that folder

### General functionality
- Lock Edits: After divider there is "Lock" button, that disabled cmd+click deletion functionality and shift+click replacing functionality. When "Lock" is active, icons are not displayed next to items when cmd or shift is pressed. When editing is locked, button label changes to "Unlock".
- Quit: Butoon to close the app

## Items structure in UI
1) Folders
2) Prompts
3) Divider between folders/prompts and other buttons.
4) Add prompt and Add folder buttons
5) Lock button
6) Quit button

Write this app from blank state and include instructions how to launch it. Use Swift with SwiftUI. Create completely new app from scratch. You are already in root folder of the directory. App name is "Spellbook".

Finally, add shell script to build the app and get application file.
```
