//
//  Crypto.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation

protocol Crypto {
    var encrypt: String { get throws }
    var decrypt: String { get throws }
}

extension String {
    var encrypt: String {
        get throws {
            try AESCrypto(source: self).encrypt
        }
    }
    
    var decrypt: String {
        get throws {
            try AESCrypto(source: self).decrypt
        }
    }
}
