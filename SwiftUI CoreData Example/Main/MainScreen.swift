//
//  Main.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 19/06/2023.
//

import SwiftUI

struct MainScreen: View {
    @StateObject var viewModel = MainViewModel()
    
    var body: some View {
        VStack {
            VStack {
                Text("Number of vehicles: \(viewModel.vehicles.count)")
                if let message = viewModel.message {
                    Text("Message: \(message)❗")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .animation(.default, value: viewModel.message)
            List {
                ForEach(viewModel.vehicles) { vehicle in
                    VStack(spacing: 6) {
                        Text("\(vehicle.id)")
                            .font(.system(size: 10).italic())
                        Text(vehicle.timestamp, formatter: itemFormatter)
                            .font(.system(size: 10).italic())
                        HStack {
                            Text(vehicle.statusString)
                            Spacer()
                            Text(vehicle.dataString)
                        }
                        .font(.system(size: 5))
                        .lineLimit(15)
                    }
                }
                .onDelete(perform: { viewModel.deleteVehicles(at: $0) })
            }
            HStack {
                Button("Add vehicle") { viewModel.addVehiclePressed() }
                Button("Clear") { viewModel.clearPressed() }
                Button("Save into\nDatabase") { viewModel.saveIntoDatabase() }
                Button("Load from\nDatabase") { viewModel.loadFromDatabase() }
            }
            .buttonStyle(.bordered)
        }
        .blur(radius: viewModel.loading ? 4 : 0)
        .overlay {
            if viewModel.loading {
                VStack(spacing: 10) {
                    ProgressView()
                        .progressViewStyle(.circular)
                    Text("Loading...")
                }
            }
        }
    }
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm:ssS"
        return formatter
    }()
}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen()
    }
}

