import SwiftUI
struct CrimeRowView: View {
    @EnvironmentObject var api: APIManager
    
    var crime: Crime
    var index: Int
    
    var body: some View {
//        NavigationLink(destination: CrimeView(crime: crime)) {
            HStack {
                Text("\(index)")
                    .font(.callout)
                    .padding()
                VStack(alignment: .leading) {
                    HStack {
                        Text("Crime id: \(String(crime.id))")
                            .font(.caption)
                        Spacer()
                        Text(crime.month)
                            .font(.caption)
                    }
                    Text(crime.location.street.name)
                        .font(.headline)
                    HStack {
                        Spacer()
                        Text(api.categoryNameFor(crime: crime))
                        Circle()
                            .fill(api.categoryColorFor(crime: crime))
                            .frame(width: 15, height: 15)
                    }


                }
            }
//        }

    }
}
