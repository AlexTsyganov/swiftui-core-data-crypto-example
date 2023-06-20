//
//  VehicleData.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation

typealias VehicleID = String

struct VehicleAllData: Identifiable {
    let id: VehicleID
    let status: VehicleStatusResponse
    let data: VehicleDataResponse
    let statusString: String
    let dataString: String
    let timestamp: Date
    
    init(id: VehicleID, status: VehicleStatusResponse, data: VehicleDataResponse, timestamp: Date = .init()) {
        self.id = id
        self.status = status
        self.data = data
        self.timestamp = timestamp
        statusString = status.jsonString
        dataString = data.jsonString
    }
    
    init() {
        self.init(id: UUID().uuidString, status: .fromFile(), data: .fromFile())
    }
}
