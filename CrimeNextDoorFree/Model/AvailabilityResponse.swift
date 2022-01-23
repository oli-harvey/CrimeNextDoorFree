//    [
//        {
//           "date" : "2015-06",
//           "stop-and-search" : [
//              "bedfordshire",
//              "cleveland",
//              "durham",
//              ...
//           ]
//        },
//        {
//           "date" : "2015-05",
//           "stop-and-search" : [
//              "bedfordshire",
//              "city-of-london",
//              "cleveland",
//              ...
//           ]
//        },
//        ...
//    ]


struct AvailabilityResponse: Codable {
    let date: String
    let stopAndSearch: [String]
    
    private enum CodingKeys: String, CodingKey {
        case date
        case stopAndSearch = "stop-and-search"
    }
}
