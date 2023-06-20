//
//  VehicleStatusEntity.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation
import CoreData

class VehicleStatusEntity: NSManagedObject {
    
}

extension VehicleStatusEntity {
    @NSManaged var vehicleId: VehicleID
    @NSManaged var status: String
    @NSManaged var data: String
    @NSManaged var timestamp: Date
}
