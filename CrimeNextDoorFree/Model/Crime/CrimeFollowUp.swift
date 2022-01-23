
//{
//    "crime": {
//        "category": "violent-crime",
//        "persistent_id": "590d68b69228a9ff95b675bb4af591b38de561aa03129dc09a03ef34f537588c",
//        "location_subtype": "",
//        "location_type": "Force",
//        "location": {
//            "latitude": "52.639814",
//            "street": {
//                "id": 883235,
//                "name": "On or near Sanvey Gate"
//            },
//            "longitude": "-1.139118"
//        },
//        "context": "",
//        "month": "2017-05",
//        "id": 56880258
//    },
//    "outcomes": [
//        {
//            "category": {
//                "code": "under-investigation",
//                "name": "Under investigation"
//            },
//            "date": "2017-05",
//            "person_id": null
//        },
//        {
//            "category": {
//                "code": "formal-action-not-in-public-interest",
//                "name": "Formal action is not in the public interest"
//            },
//            "date": "2017-06",
//            "person_id": null
//        }
//    ]
//}


struct CrimeFollowUp: Codable {
    var outcomes: [CrimeOutcome]
    let crime: Crime
}
