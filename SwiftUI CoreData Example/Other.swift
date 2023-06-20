//
//  Other.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}

extension Encodable {
    var jsonString: String {
        guard let encodedData = try? JSONEncoder().encode(self) else { return "nil" }
        return String(data: encodedData, encoding: .utf8) ?? "nil"
    }
}

extension String {
    func dataFromJson<E: Decodable>() throws -> E {
        guard let data = data(using: .utf8) else { throw "data nil from \(self)" }
        return try data.decodeJson(dateDecodingStrategy: .deferredToDate, keyDecodingStrategy: .useDefaultKeys)
    }
}

func decodeFromJsonFile<T: Decodable>(_ type: T.Type, from file: String) -> T {
    try! Bundle.main.decode(T.self, from: file)
}

extension Data {
    func decodeJson<T: Decodable>(dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .amlDateDecodingStrategy, keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = dateDecodingStrategy
        decoder.keyDecodingStrategy = keyDecodingStrategy
        return try decoder.decode(T.self, from: self)
    }
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) throws -> T {
        guard let url = url(forResource: file, withExtension: nil)  else {
            fatalError("Failed to locate \(file) in bundle.")
        }
        let data = try Data(contentsOf: url)
        return try data.decodeJson()
    }
}

extension JSONDecoder.DateDecodingStrategy {
    static let amlDateDecodingStrategy: Self = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        return try string.toDate(formatter: .iso8601)
    }
}

extension Task where Success == Never, Failure == Never {
    static func sleep(_ time: DispatchTimeInterval) async {
        try? await Task.sleep(nanoseconds: UInt64(time.nanoseconds))
    }
}

extension DispatchTimeInterval {
    var nanoseconds: Int {
        switch self {
        case .seconds(let i):
            return i * 1_000_000_000
        case .milliseconds(let i):
            return i * 1_000_000
        case .microseconds(let i):
            return i * 1_000
        case .nanoseconds(let i):
            return i
        case .never:
            return 0
        @unknown default:
            return 0
        }
    }
}
