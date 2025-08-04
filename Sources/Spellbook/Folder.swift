
import Foundation

struct Folder: Identifiable, Codable {
    var id = UUID()
    var name: String
    var children: [Node]
}
