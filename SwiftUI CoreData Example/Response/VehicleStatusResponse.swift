//
//  VehicleStatusResponse.swift
//  Connected Customer App
//
//  Created by Alex Tsyganov on 12/05/2022.
//

import Foundation

extension VehicleStatusResponse {
    static func fromFile() -> Self {
        decodeFromJsonFile(Self.self, from: "Status.json")
    }
}

enum BulbStatus: String, Codable {
    case UNKNOWN, FAILURE, ON, OFF
}
enum DoorOpenStatus: String, Codable {
    case UNKNOWN, OPEN, CLOSED
}
enum DoorLockStatus: String, Codable {
    case UNKNOWN, LOCKED, LOCKED_SAFE, UNLOCKED
}
enum WindowStatus: String, Codable {
    case UNKNOWN, OPEN, CLOSED, INTERMEDIATE
}
enum WarningLevelStatus: String, Codable {
    case UNKNOWN, NORMAL, LOW, VERY_LOW, HIGH, VERY_HIGH, RESTRICTED, IGNORE
}
enum TheftAlarmStatus: String, Codable {
    case NO_ALARM_INFO, ALARM_OFF, ALARM_ARMED, ALARM_TRIG, ALARM_TRIG_MMS, ALARM_TRIG_IS, SENSOR_FAULT
}
enum ParkingBrakeStatus: String, Codable {
    case TRUE, FALSE, UNKNOWN
}
enum PrivacyModeValue: String, Codable {
    case UNKNOWN, NONE, FULL_PRIVACY
}
enum EngineOnStatus: String, Codable {
    case TRUE, FALSE, UNKNOWN
}
enum TyrePressureWarning: String, Codable {
    case UNKNOWN, NORMAL, LOW_SOFT_WARN, LOW_HARD_WARN
}
enum TransportModeValue: String, Codable {
    case UNKNOWN, ON, OFF
}
enum LowBatteryAlertValue: String, Codable {
    case  FALSE, TRUE, UNKNOWN, EXISTS
}
enum SleepModeValue: String, Codable {
    case Unknown, Nominal, Standby, Sleep
}
enum ServiceWarningStatusValue: String, Codable {
    case UNKNOWN, NORMAL, ALMOST_TIME_FOR_SERVICE, TIME_FOR_SERVICE, TIME_EXCEEDED
}
enum ServiceWarningTriggerValue: String, Codable {
    case UNKNOWN, CALENDAR_TIME, DISTANCE, ENGINE_HOURS, OIL_CHANGE
}

public struct VehicleStatusResponse: Codable, Equatable {
    let localTimestamp = Date()
    let operationId: String
    let vehicleId: String
    let activeMode: Bool

    let alerts: Alert?
    let status: Status
    let lastUpdated: Date
    let sleepMode: SleepModeValue?

    struct Alert: Codable, Equatable {
        let alertEvent: AlertEvent?

        struct AlertEvent: Codable, Equatable {
            let lowBattery: AlertValue?

            struct AlertValue: Codable, Equatable {
                let value: LowBatteryAlertValue
            }
        }
    }
    
    struct Status: Codable, Equatable {
        let doors: Doors?
        let tires: Tyres?
        let windows: Windows?
        let exteriorLights: ExteriorLights?
        let serviceInfo: ServiceInfo?
        let isParkingBrakeEngaged: IsParkingBrakeEngaged?
        let liquidVehicle: LiquidVehicle?
        let theftAlarm: TheftAlarm?
        let warnings: Warnings?
        let odometer: Odometer?
        let tripMeters: TripMeters?
        let driveMode: DriveMode?
        let vehicleMode: VehicleMode?
        let isEngineOn: IsEngineOn?

        struct Doors: Codable, Equatable {
            let frontLeft: Door?
            let frontRight: Door?
            let rearLeft: Door?
            let rearRight: Door?
            let boot: Door?
            let bonnet: Door?
            let fuelCap: Door?

            struct Door: Codable, Equatable {
                let openStatus: OpenStatus
                let lockStatus: LockStatus

                struct OpenStatus: Codable, Equatable {
                    let value: DoorOpenStatus

                    enum CodingKeys: String, CodingKey {
                        case value = "value"
                    }
                }
                
                struct LockStatus: Codable, Equatable {
                    let value: DoorLockStatus

                    enum CodingKeys: String, CodingKey {
                        case value = "value"
                    }
                }

                enum CodingKeys: String, CodingKey {
                    case openStatus = "status"
                    case lockStatus = "lockStatus"
                }
            }

            enum CodingKeys: String, CodingKey {
                case frontLeft = "row1Left"
                case frontRight = "row1Right"
                case rearLeft = "row2Left"
                case rearRight = "row2Right"
                case boot = "trunk"
                case bonnet = "hood"
                case fuelCap = "fuelDoor"
            }
        }

        struct Tyres: Codable, Equatable {
            let frontLeft: TyrePressure?
            let frontRight: TyrePressure?
            let rearLeft: TyrePressure?
            let rearRight: TyrePressure?

            enum CodingKeys: String, CodingKey {
                case frontLeft
                case frontRight
                case rearLeft
                case rearRight
            }

            struct TyrePressure: Codable, Equatable {
                let pressureWarning: PressureWarning?
                let pressure: Pressure?

                struct PressureWarning: Codable, Equatable {
                    let value: TyrePressureWarning?
                    init(from decoder: Decoder) throws {
                        let container: KeyedDecodingContainer<VehicleStatusResponse.Status.Tyres.TyrePressure.PressureWarning.CodingKeys> = try decoder.container(keyedBy: VehicleStatusResponse.Status.Tyres.TyrePressure.PressureWarning.CodingKeys.self)
                        self.value = try? container.decodeIfPresent(TyrePressureWarning.self, forKey: VehicleStatusResponse.Status.Tyres.TyrePressure.PressureWarning.CodingKeys.value) ?? .UNKNOWN
                    }
                }

                struct Pressure: Codable, Equatable {
                    let pascal: Double?
                }
                
                init(from decoder: Decoder) throws {
                    let container: KeyedDecodingContainer<VehicleStatusResponse.Status.Tyres.TyrePressure.CodingKeys> = try decoder.container(keyedBy: VehicleStatusResponse.Status.Tyres.TyrePressure.CodingKeys.self)
                    pressureWarning = try container.decodeIfPresent(VehicleStatusResponse.Status.Tyres.TyrePressure.PressureWarning.self, forKey: VehicleStatusResponse.Status.Tyres.TyrePressure.CodingKeys.pressureWarning)
                    let pressureVal = try container.decodeIfPresent(VehicleStatusResponse.Status.Tyres.TyrePressure.Pressure.self, forKey: VehicleStatusResponse.Status.Tyres.TyrePressure.CodingKeys.pressure)

                    if pressureVal?.pascal == 254 || pressureVal?.pascal == 255 {
                        pressure = nil
                    } else {
                        pressure = pressureVal
                    }
                }

                init(pressureWarning: PressureWarning?, pressure: Pressure?) {
                    self.pressureWarning = pressureWarning
                    self.pressure = pressure
                }
            }
        }
        
        struct Windows: Codable, Equatable {
            let frontLeft: Window?
            let frontRight: Window?
            let rearLeft: Window?
            let rearRight: Window?
            let sunRoof: Window?
            let convertibleRoof: Window?

            struct Window: Codable, Equatable {
                let openStatus: OpenStatus

                struct OpenStatus: Codable, Equatable {
                    let value: WindowStatus

                    enum CodingKeys: String, CodingKey {
                        case value = "value"
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case openStatus = "status"
                }
            }

            enum CodingKeys: String, CodingKey {
                case frontLeft = "row1Left"
                case frontRight = "row1Right"
                case rearLeft = "row2Left"
                case rearRight = "row2Right"
                case sunRoof = "sunRoof"
                case convertibleRoof = "cab"
            }
        }
        
        struct ExteriorLights: Codable, Equatable {
            let parkingLightFrontLeft: Bulb?
            let parkingLightFrontRight: Bulb?

            struct Bulb: Codable, Equatable {
                let status: Status

                struct Status: Codable, Equatable {
                    let value: BulbStatus

                    enum CodingKeys: String, CodingKey {
                        case value = "value"
                    }
                }
                
                enum CodingKeys: String, CodingKey {
                    case status = "status"
                }
            }

            enum CodingKeys: String, CodingKey {
                case parkingLightFrontLeft = "parkingLightFrontLeft"
                case parkingLightFrontRight = "parkingLightFrontRight"
            }
        }

        struct ServiceInfo: Codable, Equatable {
            let daysToService: ServiceDate?
            let distanceToService: ServiceDistance?
            let serviceWarningStatus: ServiceWarningStatus?
            let serviceWarningTrigger: ServiceWarningTrigger?

            struct ServiceDate: Codable, Equatable {
                let value: Double
                
                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
            }

            struct ServiceDistance: Codable, Equatable {
                let meter: Double
            }
            
            struct ServiceWarningStatus: Codable, Equatable {
                let value: ServiceWarningStatusValue
                
                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
            }
            
            struct ServiceWarningTrigger: Codable, Equatable {
                let value: ServiceWarningTriggerValue
                
                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case daysToService = "daysToService"
                case distanceToService = "distanceToService"
                case serviceWarningStatus = "serviceWarningStatus"
                case serviceWarningTrigger = "serviceWarningTrigger"
            }
        }
        
        struct IsParkingBrakeEngaged: Codable, Equatable {
            let value: ParkingBrakeStatus

            enum CodingKeys: String, CodingKey {
                case value = "value"
            }
        }
        
        struct LiquidVehicle: Codable, Equatable {
            let fuelLevelPercentage: FuelLevelPercentage?
            let distanceToEmpty: DistanceToEmpty?
            let fuelAmount: FuelAmount?

            init(from decoder: Decoder) throws {
                typealias LiquidVehicleType = VehicleStatusResponse.Status.LiquidVehicle
                let container: KeyedDecodingContainer<LiquidVehicleType.CodingKeys> = try decoder.container(keyedBy: LiquidVehicleType.CodingKeys.self)

                if let fuelLevel = try container.decodeIfPresent(LiquidVehicleType.FuelLevelPercentage.self, forKey: LiquidVehicleType.CodingKeys.fuelLevelPercentage), fuelLevel.value != 127 {
                    fuelLevelPercentage = fuelLevel
                } else {
                    fuelLevelPercentage = nil
                }

                if let distance = try container.decodeIfPresent(LiquidVehicleType.DistanceToEmpty.self, forKey: LiquidVehicleType.CodingKeys.distanceToEmpty), distance.meter != 2047 {
                    distanceToEmpty = distance
                } else {
                    distanceToEmpty = nil
                }

                fuelAmount = try container.decodeIfPresent(LiquidVehicleType.FuelAmount.self, forKey: LiquidVehicleType.CodingKeys.fuelAmount)
            }
            
            struct FuelLevelPercentage: Codable, Equatable {
                let value: Double

                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
            }
            
            struct DistanceToEmpty: Codable, Equatable {
                let meter: Double

                enum CodingKeys: String, CodingKey {
                    case meter = "meter"
                }
            }

            struct FuelAmount: Codable, Equatable {
                let liter: Double

                enum CodingKeys: String, CodingKey {
                    case liter = "liter"
                }
            }

            enum CodingKeys: String, CodingKey {
                case fuelLevelPercentage = "fuelLevelPercentage"
                case distanceToEmpty = "distanceToEmpty"
                case fuelAmount = "fuelAmount"
            }
        }
        
        struct TheftAlarm: Codable, Equatable {
            let value: TheftAlarmStatus

            enum CodingKeys: String, CodingKey {
                case value = "value"
            }
        }
        
        struct Odometer: Codable, Equatable {
            let distance: Distance?

            init(from decoder: Decoder) throws {
                typealias OdometerType = VehicleStatusResponse.Status.Odometer
                let container: KeyedDecodingContainer<OdometerType.CodingKeys> = try decoder.container(keyedBy: OdometerType.CodingKeys.self)

                if let d = try container.decodeIfPresent(OdometerType.Distance.self, forKey: OdometerType.CodingKeys.distance), (d.meter != 16777214 || d.meter != 16777215) {
                    distance = d
                } else {
                    distance = nil
                }
            }
            
            struct Distance: Codable, Equatable {
                let meter: Double

                enum CodingKeys: String, CodingKey {
                    case meter = "meter"
                }
            }

            enum CodingKeys: String, CodingKey {
                case distance = "distance"
            }
        }
        
        struct TripMeters: Codable, Equatable {
            
            let tripMeterValues: TripMeterValues?
            
            struct TripMeterValues: Codable, Equatable {
                
                let tripMeter1: TripMeter?
                
                struct TripMeter: Codable, Equatable {
                    let odometerValue: Odometer
                    
                    enum CodingKeys: String, CodingKey {
                        case odometerValue = "odometerValue"
                    }
                }

                enum CodingKeys: String, CodingKey {
                    case tripMeter1 = "tripMeter1"
                }
                
            }
            
            enum CodingKeys: String, CodingKey {
                case tripMeterValues = "tripMeterValues"
            }
            
        }
        
        struct DriveMode: Codable, Equatable {
                let value: String

                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
        }
        
        struct VehicleMode: Codable, Equatable {
            let privacyMode: PrivacyMode?
            let transportMode: TransportMode?
            
            struct PrivacyMode: Codable, Equatable {
                let value: PrivacyModeValue?
                
                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
            }
            
            struct TransportMode: Codable, Equatable {
                let value: TransportModeValue?
                
                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
            }
            
            enum CodingKeys: String, CodingKey {
                case privacyMode = "privacyMode"
                case transportMode = "transportMode"
            }
        }
        
        struct IsEngineOn: Codable, Equatable {
                let value: EngineOnStatus

                enum CodingKeys: String, CodingKey {
                    case value = "value"
                }
        }

        enum CodingKeys: String, CodingKey {
            case doors = "doors"
            case tires = "tires"
            case windows = "windows"
            case exteriorLights = "exteriorLights"
            case serviceInfo = "serviceInfo"
            case isParkingBrakeEngaged = "isParkingBrakeEngaged"
            case liquidVehicle = "liquidVehicle"
            case theftAlarm = "theftAlarm"
            case warnings = "warnings"
            case odometer = "odometer"
            case tripMeters = "tripMeters"
            case driveMode = "driveMode"
            case vehicleMode = "vehicleMode"
            case isEngineOn = "isEngineOn"
        }

        // MARK: - Warnings
        struct Warnings: Codable, Equatable {
            let brakeFluidLevel: WarningMode?
            let engineCoolantLevel: WarningMode?
            let washerFluid: WarningMode?
            let oilLevel: WarningMode?

            enum CodingKeys: String, CodingKey {
                case brakeFluidLevel = "brakeFluidLevel"
                case engineCoolantLevel = "engineCoolantLevel"
                case washerFluid = "washerFluid"
                case oilLevel = "oilLevel"
            }
        }
    }

    // MARK: - WarningMode
    struct WarningMode: Codable, Equatable {
        let value: WarningLevelStatus

        enum CodingKeys: String, CodingKey {
            case value = "value"
        }
    }

    enum CodingKeys: String, CodingKey {
        case operationId = "operationId"
        case vehicleId = "vehicleId"
        case activeMode = "activeMode"
        case alerts = "alerts"
        case status = "status"
        case lastUpdated = "lastUpdated"
        case sleepMode = "sleepMode"
    }
}
