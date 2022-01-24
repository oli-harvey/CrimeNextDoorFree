import Foundation
import CoreLocation
import Combine
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    private let locationManager = CLLocationManager()
    @Published var locationStatus: CLAuthorizationStatus?
    @Published var lastLocation: CLLocation?
    @Published var userLatitude = 51.507222
    @Published var userLongitude = -0.1275
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04))
    
    @Published var locationShared = false
    
    var searchLocation = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
    
    var latitudeDelta = 0.01
    var longitudeDelta = 0.01
    
    // need a link back to parent controller so can change the search type back to address if no location shares
    var api: APIManager?
    

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

   
    
    var statusString: String {
        guard let status = locationStatus else {
            return "unknown"
        }
        
        switch status {
        case .notDetermined: return "notDetermined"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        case .authorizedAlways: return "authorizedAlways"
        case .restricted: return "restricted"
        case .denied: return "denied"
        default: return "unknown"
        }
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationStatus = status
        switch manager.authorizationStatus {
            case .authorizedAlways , .authorizedWhenInUse:
                locationShared = true
            default:
                locationShared = false
            if let api = api {
                api.searchType = .address
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        userLatitude = lastLocation?.coordinate.latitude ?? 51.507222
        userLongitude = lastLocation?.coordinate.longitude ?? -0.1275
    }
    
    func centreOnUser() {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: userLatitude, longitude: userLongitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    }
    
    func centreOnAddress() {
        region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: searchLocation.latitude, longitude: searchLocation.longitude), span: MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta))
    }
    
    
    func setZoom(to newZoom: Double) {
        latitudeDelta = newZoom
        longitudeDelta = newZoom
    }
    func distanceFromUser(from fromLocation: CLLocation) -> Double {
        return CLLocation(latitude: userLatitude,
                          longitude: userLongitude).distance(from: fromLocation)
    }
    
    func sortCrimeLocationsByDistance(from fromLocation: CLLocation, crimes: [Crime]) -> [Crime] {
        return crimes.sorted(by: {
            CLLocation(latitude: $0.location.latNum, longitude: $0.location.lonNum).distance(from: fromLocation) <
            CLLocation(latitude: $1.location.latNum, longitude: $1.location.lonNum).distance(from: fromLocation)
        })
        
    }
    
    func getCoordinate(fromAddress address: String,
            completionHandler: @escaping(CLLocationCoordinate2D, NSError?) -> Void ) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0] {
                    let location = placemark.location!
                        
                    completionHandler(location.coordinate, nil)
                    return
                }
            }
                
            completionHandler(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
    func requestLocationAccess() {
//        locationManager.requestAlwaysAuthorization()
        print("hi")
        locationManager.requestWhenInUseAuthorization()
    }
    
}
