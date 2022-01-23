import SwiftUI

struct ContentView: View {
    @EnvironmentObject var api: APIManager
//    @State private var crimeIsSelected = false
   
    var body: some View {
        NavigationView {
//            ScrollView {
                GeometryReader { geo in
                    Form {
                        // searcg
                        Section {
                            VStack {
                                HStack {
                                    Text("  Search From")
                                    Picker(selection: $api.searchType, label: Text("Search From")) {
                                        ForEach(SearchType.allCases, id: \.self) {
                                            Text($0.rawValue)
                                        }
                                    }
                                }
                                .padding([.top, .leading, .trailing])
                                .pickerStyle(SegmentedPickerStyle())
                                
                                if api.searchType == .address {
                                    TextField("Address:", text: $api.searchText)
                                        .transition(.scale)
                                        .animation(.easeIn)
                                }
                                
                                
                                HStack {
                                    Text("Search Month")
                                    Picker(selection: $api.dateMode, label: Text("Search Month")) {
                                        ForEach(DateMode.allCases, id: \.self) {
                                            Text($0.rawValue)
                                        }
                                    }
                                }
                                    .padding()
                                .pickerStyle(SegmentedPickerStyle())
                                
                                if api.dateMode == .historicMonth {
//                                    HStack {
                                    Picker(selection: $api.yearSelected, label: Text("Choose Year")) {
                                        ForEach(api.dateYearsAvailable, id: \.self) {
                                            Text($0)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .padding(.top)
                                    
                                    if api.hasSelectedYear {
                                        Picker(selection: $api.monthSelected, label: Text("Choose Month")) {
                                            ForEach(api.dateMonthsAvailable, id: \.self) {
                                                Text($0)
                                            }
                                        }
                                        .pickerStyle(SegmentedPickerStyle())
                                        .padding(.bottom)
                                    }

//                                    }
                                }
                                


                                HStack {
                                    Text("Max Results \(Int(api.maxResult))")
                                    Slider(value: $api.maxResult, in: 10.0...100.0, step: 5.0)
                                }
                     
                                Button("Search Crimes") {
                                    api.searchCrimes()
                                    hideKeyboard()
                                }
                                .buttonStyle(GrowingButton())
                           
                            }

                        }
                        //results
                        Section {
                            VStack {
                                Text("\(api.crimes.count) nearest of \(api.fullResults) crimes shown")
                                SearchMapView()
                                    .frame(minWidth: geo.size.width * 0.6, minHeight: geo.size.width * 0.7)
                                    .padding()
                                if api.crimes.count > 0 {
                                    VStack(alignment: .leading) {
                                        Text("Number shown is location index, see crime list below for crimes at that location.")
                                            .font(.caption)
                                        Text("Colour of map pin shows crime type. Gradient colours shown for locations with multiple crimes of different types.")
                                            .font(.caption)
                                    }
                                }

                            }
                        }
                        Section {
                            CrimeCategoryKeyView()
                        }
                            
                        Section {
                            List {
                                ForEach(api.listCrimes) { crime in
                                    NavigationLink(destination: CrimeView(crime: crime)) {
                                        CrimeRowView(crime: crime, index: api.indexFor(crime: crime))
                                    }
//                                    .onChange(of: crimeIsSelected) { (newValue) in
//                                        self.api.getCrimeFollowUp(crime: crime)
//                                    }
                                }
                            }
                        }

 
                    

//                        .frame(width: geo.size.width * 0.9, alignment: .center)
                    }
//                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .principal) {
                            HStack {
                                Image("whistle")
                                    .renderingMode(.template)
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                                Text("Crime Next Door Free")
                                    .font(.largeTitle)
                            }
                        }
                    }
//                    .navigationTitle("Crime Next Door")
//                    .ignoresSafeArea(.keyboard)
                }
            }
        .navigationViewStyle(StackNavigationViewStyle())
//        }
    }

    
}

struct ContentView_Previews: PreviewProvider {
    static let api = APIManager()
    
    static var previews: some View {
    ContentView()
        .environmentObject(api)
    }
}



//{
//    "category": "anti-social-behaviour",
//    "location_type": "Force",
//    "location": {
//        "latitude": "52.640961",
//        "street": {
//            "id": 884343,
//            "name": "On or near Wharf Street North"
//        },
//        "longitude": "-1.126371"
//    },
//    "context": "",
//    "outcome_status": null,
//    "persistent_id": "",
//    "id": 54164419,
//    "location_subtype": "",
//    "month": "2017-01"
//},
