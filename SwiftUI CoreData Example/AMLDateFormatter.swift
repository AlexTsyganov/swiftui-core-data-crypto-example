//
//  AMLDateFormatter.swift
//  Connected Customer App
//
//  Created by Alex Tsyganov on 16/05/2022.
//

import Foundation

enum AMLDateFormatter {
    case iso8601
}

extension AMLDateFormatter {
    struct UnableParseTimestamp<Value>: Error {
        let from: Value
        let formatter: AMLDateFormatter
        
        var localizedDescription: String {
            "Unable to parse the timestamp: \(from) by \(formatter)"
        }
    }
}

private extension AMLDateFormatter {
    var dateFormatter: DateFormatter? {
        switch self {
        case .iso8601:
            return nil
        }
    }
}

private extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
    
    static let amlDefault: ISO8601DateFormatter = .init()
    static let internetDateTime: ISO8601DateFormatter = .init([.withInternetDateTime])
    static let internetDateTimeWithFractionalSeconds: ISO8601DateFormatter = .init([.withFractionalSeconds, .withInternetDateTime])
    
    static let amlDefaults: [ISO8601DateFormatter] = [.amlDefault, .internetDateTime, .internetDateTimeWithFractionalSeconds]
}

extension Date {
    func toString(formatter: AMLDateFormatter) throws -> String {
        do {
            let parseError = AMLDateFormatter.UnableParseTimestamp(
                from: self,
                formatter: formatter)
            var string: String
            if formatter == .iso8601 {
                string = ISO8601DateFormatter.amlDefault.string(from: self)
            } else if let dateFormatter = formatter.dateFormatter {
                string = dateFormatter.string(from: self)
            } else {
                throw parseError
            }
            if string.isEmpty {
                throw parseError
            }
            return string
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}

extension String {
    func toDate(formatter: AMLDateFormatter) throws -> Date {
        do {
            let parseError = AMLDateFormatter.UnableParseTimestamp(
                from: self,
                formatter: formatter)
            if formatter == .iso8601 {
                for formatter in ISO8601DateFormatter.amlDefaults {
                    if let value = formatter.date(from: self) {
                        return value
                    }
                }
                throw parseError
            } else if let date = formatter.dateFormatter?.date(from: self) {
                return date
            } else {
                throw parseError
            }
        } catch {
            print(error.localizedDescription)
            throw error
        }
    }
}
