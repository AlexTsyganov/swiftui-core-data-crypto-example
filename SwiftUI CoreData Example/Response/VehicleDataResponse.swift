//
//  VehicleDataResponse.swift
//  Connected Customer App
//
//  Created by Dinesh Vijaykumar on 08/09/2022.
//

import Foundation

extension VehicleDataResponse {
    static func fromFile() -> Self {
        decodeFromJsonFile(Self.self, from: "Data.json")
    }
}

struct VehicleDataResponse: Codable, Equatable {
    let operationId: String?
    let activeDemo: Bool?
    let bodyStyle: String?
    let brand: String?
    let buildStation: String?
    let carDeliveryDate: String?
    let carStage: String?
    let carStatus: String?
    let chassisNumber: String?
    let checkInDate: String?
    let checkOutDate: String?
    let countryOfResidence: String?
    let currentDealerCode: String?
    let engineNumber: String?
    let exteriorPaintColour: String?
    let externalGUID: String?
    let gearbox: String?
    let handOfDrive: String?
    let isWarrantyStarted: Bool?
    let interiorColour1: String?
    let item: String?
    let lastModifiedById: String?
    let lastServiceCI: String?
    let lastServiceDate: String?
    let lastServiceMilage: Int?
    let mileageDate: String?
    let modelCode: String?
    let modelName: String?
    let modelYear: String?
    let myCode: String?
    let numberOfDoors: Int?
    let numberOfSeats: Int?
    let odometer: Int?
    let odometerUnits: String?
    let powerTrainType: String?
    let regionOfResidence: String?
    let registration: String?
    let status: String?
    let timeless: Bool?
    let transmission: String?
    let type: String?
    let updateCustomer: String?
    let name: String?
    let vhCode: String?
    let variantCode: String?
    let variantName: String?
    let vin: String?
    let wirelessCarIdentifier: String?
}
