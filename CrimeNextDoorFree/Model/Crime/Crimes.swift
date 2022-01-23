import Foundation
import SwiftUI

struct Crimes: Codable {
    var crimes: [Crime]
    
    private enum CodingKeys: String, CodingKey {
        case crimes
    }
}
