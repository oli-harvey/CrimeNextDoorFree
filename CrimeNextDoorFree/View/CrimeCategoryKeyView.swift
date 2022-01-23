import SwiftUI

struct CrimeCategoryKeyView: View {
    @EnvironmentObject var api: APIManager
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    
    var body: some View {
//        List {
        VStack(alignment: .leading) {
//            List(columns: columns, spacing: 10) {
                ForEach(api.crimeCategories) { category in
                    if category.crimeCount > 0 {
                        HStack {
                            Circle()
                                .fill(category.color)
                                .frame(width: 15, height: 15)
                            Text("\(category.name): \(category.crimeCount)")
                        }
                    }

                }
//            }
        }
    }
}
