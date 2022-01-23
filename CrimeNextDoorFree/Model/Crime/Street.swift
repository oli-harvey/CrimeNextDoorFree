import Foundation
import SwiftUI

struct Street: Codable {
    var id: Int
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name
    }
}
