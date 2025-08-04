
import Foundation

struct Prompt: Identifiable, Codable {
    var id = UUID()
    var name: String
    var content: String
}
