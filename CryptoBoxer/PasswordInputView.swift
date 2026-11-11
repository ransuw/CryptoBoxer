import SwiftUI
import CryptoKit
import Combine

class KeyStore: ObservableObject{
    @Published var key: SymmetricKey? = nil
}

struct PasswordInputView: View {
    @State private var password: String = ""
    @State private var rePassword: String = ""
    @State private var message: String = ""
    @State private var warning: String = ""
    @State private var iterations = 30
    @State private var salt = "CryptoBoxer"
    let memorySize = 65536
    let parallelism = 4
    @State private var passRePassword = false
    @State private var isProcessing = false
    @EnvironmentObject var keyStore: KeyStore
    @Environment(\.dismiss) private var dismiss
    
    var body: some View{
        VStack {
            Text(message)
                .font(.title)
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
            Text(warning)
                .font(.title)
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
            SecureField("パスワードを入力", text: $password)
                .frame(width: 400)
                .padding()
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    Task {
                        await submitPassword()
                        }
                }
            if passRePassword {
                SecureField("パスワードを入力(再)", text: $rePassword)
                    .frame(width: 400)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onSubmit {
                        Task {
                                await submitPassword()
                        }
                }
            }
            
            Button {
                Task {
                    await submitPassword()
                }
            } label: {
                Text("設定")
                    .padding()
                    .background((password.isEmpty || salt.isEmpty) ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(password.isEmpty || salt.isEmpty || isProcessing)
            
            Toggle("※誤ったパスワードで暗号化してしまう恐れを防止します", isOn: $passRePassword)
                .padding(.vertical, 4)
            
            HStack {
                Text("試行回数：")
                Button("▲") {
                    iterations = min(iterations + 1, 50)
                }
                Button("▼") {
                    iterations = max(iterations - 1, 10)
                }
                TextField(
                    "試行回数",
                    value: $iterations,
                    format: .number
                )
                .frame(width: 200)
                .disabled(true)
            }
            
            HStack {
                Text("ソルト：")
                TextField("CryptoBoxer", text: $salt)
                    .frame(width: 200)
            }
            
            HStack {
                Text("メモリ使用量 (KiB)：\(memorySize)")
                Text("並列度：\(parallelism)")
            }
            Text("⚠️試行回数／ソルトを少しでも変更すると生成される鍵が完全に異なるものになります。")
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .center)
        .onAppear {setMessage()}
    }
    
    func submitPassword() async {
        if password.isEmpty || salt.isEmpty {
            return
        }
        if passRePassword {
            if rePassword.isEmpty {
                warning = "パスワード(再)を入力してください。"
                return
            }
            if password != rePassword {
                warning = "パスワードが一致しません。パスワードを見直してください。"
                return
            }
        }
        do {
            isProcessing = true
            message = "⚠️ 現在設定中です。お待ちください。"
            keyStore.key = try await CryptoBoxerManager.shared.makeKey(password, salt, memorySize, iterations, parallelism)
        } catch {
            print("鍵の生成に失敗しました： \(error)")
        }
        
        dismiss()
        password = ""
        rePassword = ""
        message = ""
        warning = ""
    }
    
    func setMessage() {
        if keyStore.key != nil {
            message = "✅ パスワードは設定済みです。変更したい場合は設定し直してください。"
        } else {
            message = "❌ まだパスワードは設定されていません。"
        }
    }
}
