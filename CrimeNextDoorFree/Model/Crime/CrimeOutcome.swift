import Foundation
//        {
//            "category": {
//                "code": "under-investigation",
//                "name": "Under investigation"
//            },
//            "date": "2017-05",
//            "person_id": null
//        }


struct CrimeOutcome: Codable, Identifiable {
    var id = UUID()
    var category: CrimeOutcomeCategory
    var date: String
    
    private enum CodingKeys: String, CodingKey {
        case category, date
    }
}

struct CrimeOutcomeCategory: Codable {
    var code: String
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case code, name
    }
    
}


