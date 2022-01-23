import MapKit
import SwiftUI

class APIManager: ObservableObject {
    @Published var maxResult = 50.0
    var fullResults = 0
//    var minResult = 0
    var locationManager = LocationManager()
    
    var datesAvailable: [String] = []
    @Published var dateMonthsAvailable: [String] = []
    @Published var dateYearsAvailable: [String] = []
    
    @Published var monthSelected: String = ""
    @Published var yearSelected: String = "" {
        didSet {
            self.hasSelectedYear = true
            self.findValidMonthsForYear()
        }
    }
    @Published var hasSelectedYear = false
    
    @Published var dateMode: DateMode = .latest
    
    var crimeAnnotationPins = [AnnotatedItem]()
    // where there are duplicate crimes at same location need to give them the same index instead of their actual position in array. See index_for method for implementation
    var duplicateIndices: [Int: Int] = [:]
    
    @Published var crimes = [Crime]() {
        didSet {
            DispatchQueue.main.async {
                self.updateCrimeAnnotationPins()
                self.getCrimeFollowUps()
                self.sortListCrimesByIndex()
                self.objectWillChange.send()
            }
        }
    }
    // this annoying duplicate list is so that we can sort the list rows by index not by how close they are. If you sort the main list it will endlessly update due to the property observer
    @Published var listCrimes = [Crime]()
    
    var crimeCategories = [CrimeCategory]()
    
    @Published var searchType: SearchType = .nearest
    @Published var searchText: String = ""

    @Published var crimeFollowUps = [String: CrimeFollowUp]()
    
    var searchingForAddress = false
    
    // add crimes
    // endpoint
    // any filter selections
    
    init() {
        findDateRangeCovered()
        fetchCrimeCategories()
        centreMap()
    }
    
    func fetchCrimeCategories() {
        let urlString = buildCrimeCategoryURLString()
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let data = data {
              do {
                // decode into nested JSON format
                let newCrimeCategories = try JSONDecoder().decode([CrimeCategory].self, from: data)
                if newCrimeCategories.count > 0 {
                    print("found \(newCrimeCategories.count) crime categories")
                    
                } else {
                    print("didnt find any crime categories!")
                }
                    crimeCategories = newCrimeCategories
                    assignCrimeCategoryColors()
              } catch let jsonError as NSError {
                print("JSON decode failed: \(String(describing: jsonError))")
              }
              return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "no error given")")
        }.resume()
    }
    
    func assignCrimeCategoryColors() {
        var coloredCategories = [CrimeCategory]()
        
        for category in crimeCategories {
            print(category.name)
            let coloredCategory = category.assignColor()
            print("is assigned \(coloredCategory.color)")
            coloredCategories.append(coloredCategory)
        }
        crimeCategories = coloredCategories
    }
    
    func colorForCrime(crime: Crime) -> Color {
//        print("calling colorForCrime for crime category \(crime.category)")
        var color = Color.orange
        if let category = crimeCategories.first(where: {$0.url == crime.category}) {
//            print("category found")
            color = category.color
        }
//        print("returning \(color)")
        return color
    }
    
    func countCrimeCategories() {
        crimeCategories = crimeCategories.map { category in
            var category = category
            category.crimeCount = crimes.filter({ $0.category == category.url }).count
            return category
         }
        crimeCategories = crimeCategories.sorted { $0.crimeCount > $1.crimeCount}
    }
    
    func fetchCrimes() {
        let urlString = buildCrimeURLString()
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { [self] data, response, error in
            if let data = data {
              do {
                // decode into nested JSON format
                let newCrimes = try JSONDecoder().decode([Crime].self, from: data)
                if newCrimes.count > 0 {
                    print("found \(newCrimes.count) crimes")
                    
                }
                DispatchQueue.main.async {
                    fullResults = newCrimes.count
        
                    let maxResultNum = min(maxResult, Double(fullResults))
                    
                    var fromLocation = locationManager.lastLocation!
            
                    if searchType == .address {
                        fromLocation = CLLocation(latitude: locationManager.searchLocation.latitude, longitude: locationManager.searchLocation.longitude)
//                        locationManager.searchLocation
                    }
                    
                    let sortedNewCrimes = Array(
                       locationManager.sortCrimeLocationsByDistance(
                            from: fromLocation,
                            crimes: newCrimes
                       )[..<Int(maxResultNum)]
                    )

                    crimes = sortedNewCrimes
                    countCrimeCategories()
                    self.objectWillChange.send()
                }
              } catch let jsonError as NSError {
                print("JSON decode failed: \(String(describing: jsonError))")
              }
              return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "no error given")")
        }.resume()
    }
    
    func buildCrimeCategoryURLString() -> String {
        //return "https://data.police.uk/api/crime-categories?date=2011-08"
        return "https://data.police.uk/api/crime-categories?"
        
    }
    
    func buildCrimeURLString() -> String {
        //return "https://data.police.uk/api/crimes-street/all-crime?lat=52.629729&lng=-1.131592&date=2017-01"
        var lat = locationManager.userLatitude
        var lon = locationManager.userLongitude
        
        if self.searchType == .address && self.searchText != "" {
            lat = locationManager.searchLocation.latitude
            lon = locationManager.searchLocation.longitude
        }
        
        
        var urlString = "https://data.police.uk/api/crimes-street/all-crime?lat=\(lat)&lng=\(lon)"
        if dateMode == .historicMonth {
            urlString += "&date=\(yearSelected)-\(monthSelected)"
        }
        return urlString
    }
    
    func updateCrimeAnnotationPins() {
        self.crimeAnnotationPins.removeAll()
        self.duplicateIndices.removeAll()
        
        for crime in crimes {
            addLocationPin(
                name: crime.location_subtype,
                lat: crime.location.latNum,
                lon: crime.location.lonNum,
                crime: crime
            )
        }
    }
    
    
    func addLocationPin(name: String, lat: Double, lon: Double, crime: Crime) {
// since there can be many crimes at same location check if another exists and add to the duplicate indices list rather than create another pin

        if let originalIndex = self.crimeAnnotationPins.firstIndex(where: {$0.coordinate.latitude == lat && $0.coordinate.longitude == lon}) {
            duplicateIndices[crime.id] = originalIndex
            self.crimeAnnotationPins[originalIndex].crimesAtLocation.append(crime)
        } else {
            // no duplicate so add a pin
            var newLocation = AnnotatedItem(
                name: crime.location_subtype,
                coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                index: indexFor(crime: crime),
                color: colorForCrime(crime: crime)
            )
            newLocation.crimesAtLocation.append(crime)
            self.crimeAnnotationPins.append(newLocation)
        }

    }
    
    func indexFor(crime: Crime) -> Int {
        // if there is a key in the dictionary lookup for this its borrowing an existing crime
        // index, otherwise look up its position in the array.
        return duplicateIndices[crime.id] ?? crimes.firstIndex(of: crime) ?? 0
    }
    
    func centreMap() {
        if searchType == .address {
            locationManager.centreOnAddress()
        } else {
            locationManager.centreOnUser()
        }
    }
    
    func convertAddress(address: String) {
        locationManager.getCoordinate(fromAddress: address) { (location, error) in
            if error != nil {
                //handle error
                return
            }
            DispatchQueue.main.async {
                self.locationManager.searchLocation = location
                self.centreMap()
                self.fetchCrimes()
            }
        }
    }
    
    func searchCrimes() {
        if searchType == .address {
           convertAddress(address: searchText)
        } else {
            centreMap()
            fetchCrimes()
        }
    }
    
    func categoryNameFor(crime: Crime) -> String {
        var categoryName = crime.category
        if let category = self.crimeCategories.first(where: {$0.url == crime.category}) {
            categoryName = category.name
        }
        return categoryName
    }
    
    func categoryColorFor(crime: Crime) -> Color {
        var color = Color.orange
        if let category = self.crimeCategories.first(where: {$0.url == crime.category}) {
            color = category.color
        }
        return color
    }
    
    func findDateRangeCovered() {
    let urlString = "https://data.police.uk/api/crimes-street-dates"
    

    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        if let data = data {
          do {
            // decode into nested JSON format
            let availabilityResponses = try JSONDecoder().decode([AvailabilityResponse].self, from: data)
            DispatchQueue.main.async {
                let dates = availabilityResponses.map { $0.date }.sorted()
                var uniqueDates = Array(Set(dates))
                // remove current date as that is chosen by the main picker
                uniqueDates.removeLast()
                self.datesAvailable = uniqueDates
                let years = self.datesAvailable.compactMap { String($0.prefix(4)) }
                let uniqueYears = Array(Set(years))
                self.dateYearsAvailable = uniqueYears.sorted()
            }
          } catch let jsonError as NSError {
            print("JSON decode failed: \(String(describing: jsonError))")
          }
          return
        }
        print("Fetch failed: \(error?.localizedDescription ?? "no error given")")
    }.resume()
    }
    
    func findValidMonthsForYear() {
        let allMonths = datesAvailable.compactMap { String($0.suffix(2)) }
        print("allMonths: \(allMonths)")
        let uniqueMonths = Array(Set(allMonths))
        print("uniqueMOnths: \(uniqueMonths)")
        let validMonths = uniqueMonths.filter { datesAvailable.contains("\(self.yearSelected)-\($0)") }
        print("validMOnths: \(validMonths)")
        self.dateMonthsAvailable = validMonths.sorted()
        self.objectWillChange.send()
    }
    
    func getCrimeFollowUps() {
        for crime in self.crimes {
            getCrimeFollowUp(crime: crime)
        }
    }

    func getCrimeFollowUp(crime: Crime) {
        // https://data.police.uk/api/outcomes-for-crime/590d68b69228a9ff95b675bb4af591b38de561aa03129dc09a03ef34f537588c
        let baseURL = "https://data.police.uk/api/outcomes-for-crime/"
        let fullURL = baseURL + crime.persistent_id
        
        guard let url = URL(string: fullURL) else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
//              let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
//              print(json)
              do {
                // decode into nested JSON format
                  print("managed to decode")
                let crimeFollowUp = try JSONDecoder().decode(CrimeFollowUp.self, from: data)
                DispatchQueue.main.async {
                    self.crimeFollowUps[crime.persistent_id] = crimeFollowUp
//                    var newCrime = crime
//                    newCrime.outcomes = crimeFollowUp.outcomes
//                    if let index = self.crimes.firstIndex(of: crime) {
//                        self.crimes.remove(at: index)
//                        self.crimes.insert(newCrime, at: index)
//                        print("replaced crime with new data")
//                        self.objectWillChange.send()
//                    }
                }
              } catch let jsonError as NSError {
                print("JSON decode failed: \(String(describing: jsonError))")
              }
              return
            }
            print("Fetch failed: \(error?.localizedDescription ?? "no error given")")
        }.resume()
    }
    
    func sortListCrimesByIndex() {
        listCrimes = crimes
        listCrimes.sort(by: {
            indexFor(crime: $0) < indexFor(crime: $1)
        })
    }

    
}

