//
//  MainViewModel.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation
import Combine

@MainActor
final class MainViewModel : ObservableObject {
    private var database = AppDI.database
    @Published var vehicles = [VehicleAllData]()
    @Published var loading = false
    @Published var message: String?
    
    init() {
        _ = database.persistentContainer
    }
    
    func deleteVehicles(at offsets: IndexSet) {
        vehicles.remove(atOffsets: offsets)
    }
    
    func addVehiclePressed() {
        vehicles += [.init()]
    }
    
    func clearPressed() {
        vehicles = []
        message = nil
    }
    
    func saveIntoDatabase() {
        loading = true
        message = nil
        let vehicles = vehicles
        Worker { [weak self] in
            let table = Database.Table<VehicleStatusEntity>(in: .background)
            try await table.inContext {
                try table.clear()
                for vehicle in vehicles {
                    let entity = table.create(by: try vehicle.id.encrypt, key: "vehicleId")
                    entity.data = try vehicle.dataString.encrypt
                    entity.status = try vehicle.statusString.encrypt
                    entity.timestamp = vehicle.timestamp
                }
                try table.save()
            }
            self?.loading = false
            self?.message = "Saved success"
            self?.vehicles = []
            await Task.sleep(.seconds(3))
            self?.message = nil
        }
    }
    
    func loadFromDatabase() {
        loading = true
         Worker { [weak self] in
            let table = Database.Table<VehicleStatusEntity>(in: .background)
            let all = try await table.fetch()
            let vehicles: [VehicleAllData] = try all.map { .init(
                id: try $0.vehicleId.decrypt,
                status: try $0.status.decrypt.dataFromJson(),
                data: try $0.data.decrypt.dataFromJson(),
                timestamp: $0.timestamp)
            }
            self?.vehicles = vehicles
            self?.loading = false
            self?.message = all.isEmpty ? "Database is empty" : nil
            await Task.sleep(.seconds(3))
            self?.message = nil
        }
    }
}

extension MainViewModel {
    private func Worker(operation: @escaping () async throws -> ()) {
        Task {
            do {
                try await operation()
            } catch {
                print(error)
                message = error.localizedDescription
            }
            loading = false
        }
    }
}
