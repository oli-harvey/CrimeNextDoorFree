import Foundation
import SwiftUI

struct Location: Codable {
    var latitude: String
    var street: Street
    var longitude: String
    
    var latNum: Double {
        return Double(latitude) ?? 51.507222
    }
    
    var lonNum: Double {
        return Double(longitude) ?? -0.1275
    }
    
    private enum CodingKeys: String, CodingKey {
        case latitude, street, longitude
    }
}

