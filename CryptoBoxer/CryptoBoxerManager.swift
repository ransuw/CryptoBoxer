import Foundation
import CryptoKit
import AppKit
import SwiftArgon2
import Combine

class CryptoBoxerManager: ObservableObject {
    @Published var isKeySet: Bool = false
    static let shared = CryptoBoxerManager()
    private var keyStore: SymmetricKey?
    
    func makeKey(_ password: String, _ salt: String, _ memorySize: Int, _ iterations: Int, _ parallelism: Int) async throws {
        let passwordData = Data(password.utf8)
        let saltData = Data(salt.utf8)
        
        let argon2 = try Argon2(params: Argon2Params(
            parallelism: UInt32(parallelism),
            tagLength: 32,
            memorySize: UInt32(memorySize),
            iterations:  UInt32(iterations),
            variant: .argon2id
        ))
        
        let keyData = try await argon2.compute(
            password: passwordData,
            salt: saltData
        )
        
        keyStore = SymmetricKey(data: keyData)
        isKeySet = true
    }
    
    func encrypt(data: Data) throws -> Data {
        let sealedBox = try AES.GCM.seal(data, using: keyStore!)
        guard let combined = sealedBox.combined else {
            throw NSError(domain: "EncryptionError", code: 0, userInfo: nil)
        }
        return combined
    }
    
    func decrypt(data: Data) throws -> Data {
        let sealedBox = try AES.GCM.SealedBox(combined: data)
        return try AES.GCM.open(sealedBox, using: keyStore!)
    }
    
    func getFolderPath(folderName: String) throws -> URL {
        let fileManager = FileManager.default
        let appSupport = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let folderPath = appSupport
            .appendingPathComponent("CryptoBoxer")
            .appendingPathComponent(folderName)
        
        try fileManager.createDirectory(
            at: folderPath,
            withIntermediateDirectories: true,
            attributes: nil
        )
        return folderPath
    }
    
    func openFinder(folderName: String) {
        let fileManager = FileManager.default
        guard let appSupport = try? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else {
            return
        }
        
        let folderPath = appSupport
            .appendingPathComponent("CryptoBoxer")
            .appendingPathComponent(folderName)
        NSWorkspace.shared.open(folderPath)
    }
    
    func clearFiles(folderName: String) {
        let fileManager = FileManager.default
        guard let folder = try? CryptoBoxerManager.shared.getFolderPath(folderName: folderName) else {return}
        let files = (try? fileManager.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)) ?? []
        for file in files {
            try? fileManager.removeItem(at: file)
        }
    }
}
