import SwiftUI

@main
struct CryptoBoxerApp: App {
    @StateObject var keyStore = KeyStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(keyStore)
                .frame(width: 700, height: 700)
        }
        .windowResizability(.contentSize)
    }
}

