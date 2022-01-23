import MapKit
import SwiftUI

struct NumberedMapPin: View {
    @State var colors: [Color]
    var index: Int
    var body: some View {
       VStack {
           LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing)
               .mask(
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    ).frame(width: 20, height: 20, alignment: .center)
               .overlay(
                    Text("\(index)")
                        .offset(x: 0, y: -12)
                        .font(.caption)
               )
//            Image(systemName: "mappin.circle.fill")
//               .mask(LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom))
//                .overlay(
//                    Text("\(index)")
//                        .offset(x: 5, y: -10)
//                        .font(.callout)
////                        .foregroundColor(.orange)
//                        .fixedSize()
//                )
//           Circle()
//               .fill(LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom))
//               .mask(Image(systemName: "mapping.circle"))
        }
       .onAppear {
           print(colors)
       }

    }
}
