import MapKit
import SwiftUI

struct LabelledMapPin: View {
    var item: AnnotatedItem
    var body: some View {
       VStack {
            Text("")
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.orange)
           Text(item.name)
                .font(.caption)
                .foregroundColor(.orange)
                .fixedSize()
        }

    }
}
