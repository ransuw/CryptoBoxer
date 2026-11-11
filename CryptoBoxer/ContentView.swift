import SwiftUI

struct ContentView: View {
    @EnvironmentObject var keyStore: KeyStore
    @State private var passwordMessaga = ""
    @State private var importMessaga = ""
    @State private var cryptedMessaga = ""
    @State private var manualMessage = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                NavigationLink {
                    PasswordInputView()
                } label: {
                    Text(passwordMessaga)
                        .frame(maxWidth: 560)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink {
                    UploadView()
                } label: {
                    Text(importMessaga)
                        .frame(maxWidth: 560)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink {
                    ViewerView()
                } label: {
                    Text(cryptedMessaga)
                        .frame(maxWidth: 560)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                NavigationLink {
                    ManualView()
                } label: {
                    Text(manualMessage)
                        .frame(maxWidth: 560)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
            .onAppear {
                setMessage()
            }
            .onChange(of: keyStore.key != nil) {
                setMessage()
            }
        }
    }
    
    func setMessage() {
        manualMessage = "操作説明"
        
        if keyStore.key != nil {
            passwordMessaga = "パスワード設定／鍵生成⭕️"
            importMessaga = "平文ファイル取り込み🔑"
            cryptedMessaga = "暗号化済みファイル一覧🔑"
        } else {
            passwordMessaga = "パスワード設定／鍵生成❌"
            importMessaga = "平文ファイル取り込み🔒"
            cryptedMessaga = "暗号化済みファイル一覧🔒"
        }
    }
}

#Preview {
    ContentView()
}
