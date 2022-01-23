import Foundation
import SwiftUI

struct Crime: Codable, Identifiable, Equatable {
    static func == (lhs: Crime, rhs: Crime) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var persistent_id: String
    var category: String
    var location_type: String
    var location: Location
    var context: String
//    var outcome_status: String?
    var location_subtype: String
    var month: String
    
    private enum CodingKeys: String, CodingKey {
        case id, category, location_type, location, context, location_subtype, month, persistent_id
    }
    
//    var outcomes = [CrimeOutcome]()
   
}

extension Crime {
    static func example() -> Crime {
        let example = Crime(
            id: 1,
            persistent_id: "123abc",
            category: "anti-social-behaviour",
            location_type: "Force",
            location: Location(
                latitude: "52.640961",
                street: Street(
                    id: 884343,
                    name: "On or near Wharf Street North"),
                longitude: "-1.126371"),
            context: "",
            location_subtype: "",
            month: "2017-01")
        return example
    }
}

