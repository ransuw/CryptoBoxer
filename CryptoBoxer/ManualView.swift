import SwiftUI

struct ManualView: View {
    var body: some View {
        ScrollView(.vertical) {
            VStack() {
                Image("manual0")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 560, maxHeight: 400)
                    .clipped()
                Image("manual1")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 560, maxHeight: 400)
                    .clipped()
                Image("manual2")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 560, maxHeight: 400)
                    .clipped()
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
    }
}
