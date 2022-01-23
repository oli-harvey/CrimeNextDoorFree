//
//  CrimeView.swift
//  CrimeNextDoor
//
//  Created by Oliver Harvey on 03/09/2021.
//

import SwiftUI

struct CrimeView: View {
    @EnvironmentObject var api: APIManager
    
    var crime: Crime
    var body: some View {
        GeometryReader { geo in
            Form {
                Group {
                    CrimeRowView(crime: crime, index: api.indexFor(crime: crime))
                }
                // map of crime
                // follow up if found
                Group {
                    if let followUp = api.crimeFollowUps[crime.persistent_id] {
                        List(followUp.outcomes) { outcome in
                            Text(outcome.category.name)
                        }

                    } else {
                        Text("There is currently no outcome available for this Crime")
                            .font(.caption)

                    }

                }
                Group {
                    CrimeMapView(crime: crime)
                        .frame(minWidth: geo.size.width * 0.6, minHeight: geo.size.width * 0.7)
                }
            }
        }
    }
}

struct CrimeView_Previews: PreviewProvider {
    static var previews: some View {
        CrimeView(crime: Crime.example())
    }
}

