import SwiftUI
import CryptoKit
import Combine

struct PasswordInputView: View {
    @ObservedObject var cryptoBoxerManager = CryptoBoxerManager.shared
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
    @Environment(\.dismiss) private var dismiss
    @State private var isLeftButtonInvalid = false
    @State private var isRightButtonInvalid = true
    @State private var isButtonsInvalid = false
    @State private var tmpSalt = "CryptoBookmark"
    
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
                Button("◀︎") {
                    Task{
                        await leftButton()
                    }
                }
                .disabled(isLeftButtonInvalid)
                Button("▶︎") {
                    Task{
                        await rightButton()
                    }
                }
                .disabled(isRightButtonInvalid)
                TextField("任意のソルトを入力してください。", text: $salt)
                    .frame(width: 200)
                    .onChange(of: salt) {
                        Task {
                            await saltButtonControl()
                        }
                    }
                    .disabled(!isButtonsInvalid)
                    .onSubmit {
                        Task {
                            await submitPassword()
                        }
                    }
                Button("入力") {
                    Task{
                        await inputButton()
                    }
                }
                .disabled(isButtonsInvalid)
            }
            
            HStack {
                Text("メモリ使用量 (KiB)：\(memorySize)")
                Text("並列度：\(parallelism)")
            }
            Text("⚠️試行回数／ソルトを少しでも変更すると生成される鍵が完全に異なるものになります。")
            Text("⚠️ソルトには8バイト以上の文字列が必要になります。")
        }
        .padding()
        .frame(maxHeight: .infinity, alignment: .center)
        .onAppear {setMessage()}
    }
    
    private func submitPassword() async {
        if password.isEmpty || salt.isEmpty {
            return
        }
        if (salt.utf8.count < 8) {
            warning = "8バイト以上のソルトを入力してください。"
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
            try await CryptoBoxerManager.shared.makeKey(password, salt, memorySize, iterations, parallelism)
        } catch {
            warning = "鍵の生成に失敗しました。"
        }
        
        password = ""
        rePassword = ""
        message = ""
        warning = ""
        dismiss()
    }
    
    private func setMessage() {
        if cryptoBoxerManager.isKeySet {
            message = "✅ パスワードは設定済みです。変更したい場合は設定し直してください。"
        } else {
            message = "❌ まだパスワードは設定されていません。"
        }
    }
    
    private func leftButton() async {
        salt = String(salt.dropLast())
    }
    
    private func rightButton() async {
        let saltLength = salt.count
        let tmpSaltLength = tmpSalt.count
        if (saltLength < tmpSaltLength) {
            salt = String(tmpSalt.prefix(saltLength + 1))
        }
    }
    
    private func saltButtonControl() async {
        if (!isButtonsInvalid) {
            let saltLength = salt.count
            let tmpSaltLength = tmpSalt.count
            if (saltLength == tmpSaltLength) {
                isRightButtonInvalid = true
            } else {
                isRightButtonInvalid = false
            }
            if (saltLength <= 1) {
                isLeftButtonInvalid = true
            } else {
                isLeftButtonInvalid = false
            }
        }
    }
    
    private func inputButton() async {
        isLeftButtonInvalid = true
        isRightButtonInvalid = true
        isButtonsInvalid = true
        salt = ""
    }
}
