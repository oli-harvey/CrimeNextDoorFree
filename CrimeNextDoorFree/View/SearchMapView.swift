import MapKit
import SwiftUI

struct SearchMapView: View {
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.4))
    @EnvironmentObject var apiManager: APIManager
    
    var body: some View {
        VStack {
            Map(coordinateRegion: $apiManager.locationManager.region, showsUserLocation: true, annotationItems: apiManager.crimeAnnotationPins) { item in
                MapAnnotation(coordinate: item.coordinate) {
                    NumberedMapPin(
                        colors: item.crimesAtLocation.map { apiManager.categoryColorFor(crime: $0) },
                        index: item.index
                    )
                }
            }
            .padding(.horizontal)
        }
    }
        
}

struct SearchMapView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMapView()
    }
}



