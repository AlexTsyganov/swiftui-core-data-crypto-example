//
//  DI.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation

final class DI {
    static let shared = DI()
    
    lazy var database = Database.instance
}

let AppDI = DI.shared
