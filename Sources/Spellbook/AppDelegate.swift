import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarItem: NSStatusItem!
    let menu = NSMenu()
    var nodes: [Node] = []
    var modifierTimer: Timer?
    var lastModifierFlags: NSEvent.ModifierFlags = []
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: "book.closed.fill", accessibilityDescription: "Spellbook")
            statusBarItem.menu = menu
        }
        
        loadNodes()
        startModifierMonitoring()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        modifierTimer?.invalidate()
        modifierTimer = nil
    }
    
    func constructMenu() {
        menu.removeAllItems()
        
        // Sort nodes: folders first, then prompts
        let sortedNodes = nodes.sorted { (node1, node2) in
            switch (node1, node2) {
            case (.folder, .prompt):
                return true
            case (.prompt, .folder):
                return false
            case (.folder(let folder1), .folder(let folder2)):
                return folder1.name < folder2.name
            case (.prompt(let prompt1), .prompt(let prompt2)):
                return prompt1.name < prompt2.name
            }
        }
        
        for node in sortedNodes {
            menu.addItem(createMenuItem(for: node))
        }
        
        menu.addItem(NSMenuItem.separator())
        
        let addPromptMenuItem = NSMenuItem(title: "Add Prompt", action: #selector(addPrompt), keyEquivalent: "")
        addPromptMenuItem.target = self
        menu.addItem(addPromptMenuItem)
        
        let addFolderMenuItem = NSMenuItem(title: "Add Folder", action: #selector(addFolder), keyEquivalent: "")
        addFolderMenuItem.target = self
        menu.addItem(addFolderMenuItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitMenuItem = NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitMenuItem)
    }
    
    func createMenuItem(for node: Node) -> NSMenuItem {
        switch node {
        case .prompt(let prompt):
            let menuItem = NSMenuItem(title: getDisplayTitle(for: node), action: #selector(promptAction(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = prompt
            return menuItem
        case .folder(let folder):
            let menuItem = NSMenuItem(title: getDisplayTitle(for: node), action: #selector(folderAction(_:)), keyEquivalent: "")
            menuItem.target = self
            menuItem.representedObject = folder
            let submenu = NSMenu()
            // Sort children: folders first, then prompts
            let sortedChildren = folder.children.sorted { (node1, node2) in
                switch (node1, node2) {
                case (.folder, .prompt):
                    return true
                case (.prompt, .folder):
                    return false
                case (.folder(let folder1), .folder(let folder2)):
                    return folder1.name < folder2.name
                case (.prompt(let prompt1), .prompt(let prompt2)):
                    return prompt1.name < prompt2.name
                }
            }
            for child in sortedChildren {
                submenu.addItem(createMenuItem(for: child))
            }
            submenu.addItem(NSMenuItem.separator())
            let addPromptMenuItem = NSMenuItem(title: "Add Prompt", action: #selector(addPromptToFolder(_:)), keyEquivalent: "")
            addPromptMenuItem.target = self
            addPromptMenuItem.representedObject = folder
            submenu.addItem(addPromptMenuItem)
            let addFolderMenuItem = NSMenuItem(title: "Add Folder", action: #selector(addFolderToFolder(_:)), keyEquivalent: "")
            addFolderMenuItem.target = self
            addFolderMenuItem.representedObject = folder
            submenu.addItem(addFolderMenuItem)
            menuItem.submenu = submenu
            return menuItem
        }
    }
    
    func getDisplayTitle(for node: Node) -> String {
        let baseName: String
        switch node {
        case .prompt(let prompt):
            baseName = truncateString(prompt.name, maxLength: 25)
        case .folder(let folder):
            baseName = truncateString(folder.name, maxLength: 25)
        }
        
        let flags = NSEvent.modifierFlags
        if flags.contains(.command) {
            return "🗑 \(baseName)"
        } else if flags.contains(.shift) {
            switch node {
            case .prompt:
                return "✏️ \(baseName)"
            case .folder:
                return baseName
            }
        }
        
        return baseName
    }
    
    func truncateString(_ string: String, maxLength: Int) -> String {
        if string.count <= maxLength {
            return string
        }
        let truncatedIndex = string.index(string.startIndex, offsetBy: maxLength - 3)
        return String(string[..<truncatedIndex]) + "..."
    }
    
    func startModifierMonitoring() {
        modifierTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let currentFlags = NSEvent.modifierFlags
            if currentFlags != self.lastModifierFlags {
                self.lastModifierFlags = currentFlags
                self.updateMenuTitles()
            }
        }
    }
    
    func updateMenuTitles() {
        updateMenuItemTitles(in: menu)
    }
    
    func updateMenuItemTitles(in menu: NSMenu) {
        for item in menu.items {
            if let prompt = item.representedObject as? Prompt {
                item.title = getDisplayTitle(for: .prompt(prompt))
            } else if let folder = item.representedObject as? Folder, 
                      item.action == #selector(folderAction(_:)) {
                // Only update folder items that have folderAction, not "Add Prompt"/"Add Folder" buttons
                item.title = getDisplayTitle(for: .folder(folder))
                if let submenu = item.submenu {
                    updateMenuItemTitles(in: submenu)
                }
            }
        }
    }
    
    @objc func promptAction(_ sender: NSMenuItem) {
        guard let prompt = sender.representedObject as? Prompt else { return }
        
        let currentEvent = NSApp.currentEvent
        let flags = currentEvent?.modifierFlags ?? NSEvent.modifierFlags
        
        if flags.contains(.command) {
            deleteNode(with: prompt.id)
        } else if flags.contains(.shift) {
            replacePrompt(with: prompt.id)
        } else {
            copyPrompt(prompt)
        }
    }
    
    @objc func folderAction(_ sender: NSMenuItem) {
        guard let folder = sender.representedObject as? Folder else { return }
        
        let currentEvent = NSApp.currentEvent
        let flags = currentEvent?.modifierFlags ?? NSEvent.modifierFlags
        
        if flags.contains(.command) {
            deleteNode(with: folder.id)
        } else {
            copyAllPromptsFromFolder(folder)
        }
    }
    
    func copyPrompt(_ prompt: Prompt) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(prompt.content, forType: .string)
    }
    
    func collectAllPrompts(from folder: Folder, basePath: String = "") -> [(path: String, prompt: Prompt)] {
        var allPrompts: [(path: String, prompt: Prompt)] = []
        let currentPath = basePath.isEmpty ? folder.name : "\(basePath)/\(folder.name)"
        
        for child in folder.children {
            switch child {
            case .prompt(let prompt):
                allPrompts.append((path: currentPath, prompt: prompt))
            case .folder(let childFolder):
                allPrompts.append(contentsOf: collectAllPrompts(from: childFolder, basePath: currentPath))
            }
        }
        
        return allPrompts
    }
    
    func copyAllPromptsFromFolder(_ folder: Folder) {
        let allPrompts = collectAllPrompts(from: folder)
        
        if allPrompts.isEmpty {
            return
        }
        
        let formattedContent = allPrompts.map { promptInfo in
            let header = "=== \(promptInfo.path)/\(promptInfo.prompt.name) ==="
            return "\(header)\n\(promptInfo.prompt.content)"
        }.joined(separator: "\n\n")
        
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(formattedContent, forType: .string)
    }
    
    func deleteNode(with id: UUID, from nodes: inout [Node]) -> Bool {
        for (index, node) in nodes.enumerated() {
            if node.id == id {
                nodes.remove(at: index)
                return true
            }
            if case .folder(var folder) = node {
                if deleteNode(with: id, from: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }
        return false
    }
    
    func deleteNode(with id: UUID) {
        if deleteNode(with: id, from: &nodes) {
            saveNodes()
            constructMenu()
        }
    }
    
    func replacePrompt(with id: UUID, in nodes: inout [Node]) -> Bool {
        for (index, node) in nodes.enumerated() {
            if node.id == id {
                if case .prompt(var prompt) = node {
                    let pasteboard = NSPasteboard.general
                    if let newContent = pasteboard.string(forType: .string) {
                        prompt.content = newContent
                        nodes[index] = .prompt(prompt)
                        return true
                    }
                }
            }
            if case .folder(var folder) = node {
                if replacePrompt(with: id, in: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }
        return false
    }
    
    func replacePrompt(with id: UUID) {
        if replacePrompt(with: id, in: &nodes) {
            saveNodes()
            constructMenu()
        }
    }
    
    @objc func addPrompt() {
        let pasteboard = NSPasteboard.general
        if let content = pasteboard.string(forType: .string) {
            let lines = content.split(separator: "\n")
            let name = String(lines.first ?? "New Prompt")
            let promptContent = lines.dropFirst().joined(separator: "\n")
            let newPrompt = Prompt(name: name, content: promptContent)
            nodes.append(.prompt(newPrompt))
            saveNodes()
            constructMenu()
        }
    }
    
    @objc func addFolder() {
        let alert = NSAlert()
        alert.messageText = "New Folder"
        alert.informativeText = "Enter a name for the new folder:"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        alert.accessoryView = textField
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            let folderName = textField.stringValue
            if !folderName.isEmpty {
                let newFolder = Folder(name: folderName, children: [])
                nodes.append(.folder(newFolder))
                saveNodes()
                constructMenu()
            }
        }
    }
    
    @objc func addPromptToFolder(_ sender: NSMenuItem) {
        guard let folder = sender.representedObject as? Folder else { return }
        addPromptToFolder(withId: folder.id)
    }
    
    func addPromptToFolder(withId id: UUID, in nodes: inout [Node]) -> Bool {
        for (index, node) in nodes.enumerated() {
            if node.id == id {
                if case .folder(var folder) = node {
                    let pasteboard = NSPasteboard.general
                    if let content = pasteboard.string(forType: .string) {
                        let lines = content.split(separator: "\n")
                        let name = String(lines.first ?? "New Prompt")
                        let promptContent = lines.dropFirst().joined(separator: "\n")
                        let newPrompt = Prompt(name: name, content: promptContent)
                        folder.children.append(.prompt(newPrompt))
                        nodes[index] = .folder(folder)
                        return true
                    }
                }
            }
            if case .folder(var folder) = node {
                if addPromptToFolder(withId: id, in: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }
        return false
    }
    
    func addPromptToFolder(withId id: UUID) {
        if addPromptToFolder(withId: id, in: &nodes) {
            saveNodes()
            constructMenu()
        }
    }
    
    @objc func addFolderToFolder(_ sender: NSMenuItem) {
        guard let folder = sender.representedObject as? Folder else { return }
        addFolderToFolder(withId: folder.id)
    }
    
    func addFolderToFolder(withId id: UUID, in nodes: inout [Node]) -> Bool {
        for (index, node) in nodes.enumerated() {
            if node.id == id {
                if case .folder(var folder) = node {
                    let alert = NSAlert()
                    alert.messageText = "New Folder"
                    alert.informativeText = "Enter a name for the new folder:"
                    alert.addButton(withTitle: "OK")
                    alert.addButton(withTitle: "Cancel")
                    
                    let textField = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
                    alert.accessoryView = textField
                    
                    let response = alert.runModal()
                    
                    if response == .alertFirstButtonReturn {
                        let folderName = textField.stringValue
                        if !folderName.isEmpty {
                            let newFolder = Folder(name: folderName, children: [])
                            folder.children.append(.folder(newFolder))
                            nodes[index] = .folder(folder)
                            return true
                        }
                    }
                }
            }
            if case .folder(var folder) = node {
                if addFolderToFolder(withId: id, in: &folder.children) {
                    nodes[index] = .folder(folder)
                    return true
                }
            }
        }
        return false
    }
    
    func addFolderToFolder(withId id: UUID) {
        if addFolderToFolder(withId: id, in: &nodes) {
            saveNodes()
            constructMenu()
        }
    }
    
    func loadNodes() {
        PromptStore.load { result in
            switch result {
            case .success(let nodes):
                self.nodes = nodes
                DispatchQueue.main.async {
                    self.constructMenu()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self.nodes = []
                DispatchQueue.main.async {
                    self.constructMenu()
                }
            }
        }
    }
    
    func saveNodes() {
        PromptStore.save(nodes: nodes) { result in
            if case .failure(let error) = result {
                print(error.localizedDescription)
            }
        }
    }
}
