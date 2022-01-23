import MapKit
import SwiftUI

struct CrimeMapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.3))
    @EnvironmentObject var apiManager: APIManager
    @State var crime: Crime
    
    var body: some View {
        Map(coordinateRegion: $apiManager.locationManager.region,
            showsUserLocation: true,
            annotationItems: apiManager.crimeAnnotationPins.filter { $0.crimesAtLocation.contains(crime) }) { item in
            MapAnnotation(coordinate: item.coordinate) {
                NumberedMapPin(colors: [apiManager.categoryColorFor(crime: crime)], index: item.index)
            }

        }
        .padding(.horizontal)
    }

}




