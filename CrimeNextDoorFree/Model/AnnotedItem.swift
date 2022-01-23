import SwiftUI
import MapKit

struct AnnotatedItem: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
    var index: Int
    var color: Color
    var crimesAtLocation = [Crime]()
}
    
