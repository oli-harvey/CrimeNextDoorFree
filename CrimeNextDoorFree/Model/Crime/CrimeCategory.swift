import Foundation
import SwiftUI
//{
//    "url": "all-crime",
//    "name": "All crime and ASB"
//}
struct CrimeCategory: Codable, Identifiable {
    let id = UUID()
    let url: String
    let name: String
    var color: Color = .orange
    var crimeCount: Int = 0
    
    private enum CodingKeys: String, CodingKey {
        case url, name
    }
    
    static var colours: [Color] = [
        Color.blue,
//        Color.brown,
        Color.black,
//        Color.cyan,
        Color.green,
        Color.gray,
        Color.pink,
//        Color.mint,
        Color.purple,
        Color.red,
//        Color.teal,
        Color.yellow,
    ]
    func assignColor() -> CrimeCategory {

        var newColor = Color.orange
        if let newColorPopped = Self.colours.popLast() {
            newColor = newColorPopped
        } else {
            newColor = Color.random
        }
        
        return CrimeCategory(url: self.url, name: self.name, color: newColor)
    }
}
