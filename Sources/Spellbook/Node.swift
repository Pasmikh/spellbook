
import Foundation

enum Node: Identifiable, Codable {
    case prompt(Prompt)
    case folder(Folder)
    
    var id: UUID {
        switch self {
        case .prompt(let prompt):
            return prompt.id
        case .folder(let folder):
            return folder.id
        }
    }
}
