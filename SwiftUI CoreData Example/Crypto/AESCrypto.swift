//
//  AESCrypto.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation
import CryptoSwift

struct AESCrypto: Crypto {
    let source: String
    
    var encrypt: String {
        get throws {
            let data = source.data(using: .utf8)!
            let key = Array(encryptionKey.utf8)
            let encrypted = try AES(key: key, blockMode: ECB()).encrypt([UInt8](data))
            let encryptedData = Data(encrypted)
            return encryptedData.base64EncodedString()
        }
    }
    
    var decrypt: String {
        get throws {
            guard let data = Data(base64Encoded: source) else { throw "Unable base64Encoded form \(source)" }
            let key = Array(encryptionKey.utf8)
            let decrypted = try AES(key: key, blockMode: ECB()).decrypt([UInt8](data))
            let decryptedData = Data(decrypted)
            guard let result = String(bytes: decryptedData.bytes, encoding: .utf8) else { throw "Could not decrypt from \(source)" }
            return result
        }
    }
    private let encryptionKey = "sfj$cPAH%kXNMj2N"
}
