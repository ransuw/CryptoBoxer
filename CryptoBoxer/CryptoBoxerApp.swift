import SwiftUI

@main
struct CryptoBoxerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 700, height: 700)
        }
        .windowResizability(.contentSize)
    }
}
