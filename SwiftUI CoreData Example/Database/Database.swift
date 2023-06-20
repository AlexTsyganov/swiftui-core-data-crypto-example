//
//  Database.swift
//  SwiftUI CoreData Example
//
//  Created by Alex Tsyganov on 20/06/2023.
//

import Foundation
import CoreData

final class Database {
    static var instance = Database()

    enum Context {
        case main, background, own(NSManagedObjectContext)
        
        var thread: NSManagedObjectContext {
            switch self {
                case .main: return Database.mainContext
                case .background: return Database.backgroundContext
                case .own(let context): return context
            }
        }
    }
    
    class Table<E: NSManagedObject> {
        private let context: NSManagedObjectContext
        var fetchRequest: NSFetchRequest<E> {
            let request = NSFetchRequest<E>()
            request.entity = E.entity()
            return request
        }
        
        init() {
            context = Database.mainContext
        }
        
        required init(in context: Context) {
            self.context = context.thread
        }
        
        required init(in context: NSManagedObjectContext) {
            self.context = context
        }
        
        func get(_ objID: NSManagedObjectID) -> E {
            context.object(with: objID) as! E
        }

        func create(by id: Any? = nil, key: String = "id") -> E {
            E.create(by: id, key: key, in: context)
        }
        
        func inContext(_ block: @escaping (NSManagedObjectContext) -> Void) {
            context.perform { [ctx = self.context] in block(ctx) }
        }
        
        func fetch(_ momRequestID: String, params: [String: Any]? = nil, sort: [(key: String, isAscending: Bool)]? = nil, _ onResult: @escaping ([E]) -> Void) {
            let context = self.context
            context.perform {
                guard let request = Database.momRequest(identifier: momRequestID, sort: sort, params: params) else {
                    DispatchQueue.main.async { onResult([]) }
                    return
                }
                let data = (try? context.fetch(request)) as? [E]
                DispatchQueue.main.async { onResult(data ?? []) }
                _ = context
            }
        }
        
        func fetch() async throws -> [E] {
            let fetchRequest = self.fetchRequest
            return try await context.perform(schedule: .immediate) { [weak self] in
                guard let context = self?.context else { return [] }
                return try context.fetch(fetchRequest)
            }
        }
        
        func inContext(_ block: @escaping () throws -> Void) async throws {
            try await context.perform(schedule: .immediate) {
                try block()
            }
        }
        
        func fetch(sort: ((E, E) -> Bool)? = nil, filter: ((E) -> Bool)? = nil, _ onResult: @escaping ([E]) -> Void) {
            let fetchRequest = self.fetchRequest
            context.perform { context in
                var data = try? context.fetch(fetchRequest)
                if let filter {
                    data = data?.filter(filter)
                }
                if let sort {
                    data = data?.sorted(by: sort)
                }
                DispatchQueue.main.async { onResult(data ?? []) }
            }
        }
        
        func synch(_ filter: (E) -> Bool = { _ in true }) throws {
            try context.fetch(fetchRequest)
                .filter { filter($0) && $0.unattended() }
                .forEach { $0.delete(); print("Removed: \($0)") }
        }
        
        func clear() throws {
            let request = NSFetchRequest<NSFetchRequestResult>()
            request.entity = E.entity()
            request.predicate = NSPredicate(value: true)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            try context.execute(deleteRequest)
        }
        
        func save() throws {
            guard context.hasChanges else { return }
            try context.save()
            if let parentTable = context.parent?.table(E.self) {
                try parentTable.save()
            }
        }
    }
    
    static func resetAll() {
        mainContext.reset()
        do {
            for entity in instance.persistentContainer.managedObjectModel.entities {
                let request = NSFetchRequest<NSFetchRequestResult>()
                request.entity = entity
                request.predicate = NSPredicate(value: true)
                let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
                _ = try mainContext.execute(deleteRequest)
            }
            try mainContext.save()
        } catch {
            mainContext.rollback()
            print(error)
        }
    }
    
    static func reset<E: NSManagedObject>(_ classTypes: [E.Type] = []) {
        guard !classTypes.isEmpty else {
            resetAll()
            return
        }
        mainContext.reset()
        do {
            for classType in classTypes {
                try mainContext.table(classType).clear()
            }
            try mainContext.save()
        } catch {
            mainContext.rollback()
            print(error)
        }
    }
    
    static var mainContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.persistentStoreCoordinator = instance.persistentContainer.persistentStoreCoordinator
        context.stalenessInterval = 0.0
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }()

    static var backgroundContext: NSManagedObjectContext {
        let context = instance.persistentContainer.newBackgroundContext()
        context.stalenessInterval = 0.0
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }
    
    static func task(_ block: @escaping (NSManagedObjectContext) -> Void) {
        instance.persistentContainer.performBackgroundTask(block)
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let description = NSPersistentStoreDescription()
        description.shouldInferMappingModelAutomatically = true
        description.shouldMigrateStoreAutomatically = true
        description.url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("Database.sqlite")
        let container = NSPersistentContainer(name: "Database")
        container.persistentStoreDescriptions = [description]
        print("Database: \(description.url!)")
        container.loadPersistentStores { [unowned self] (storeDescription, error) in
            if let error = error as NSError? {
                try? FileManager.default.removeItem(at: description.url!)
                container.loadPersistentStores { (storeDescription, error) in
                    if let error = error as NSError? {
                        print(error)
                        fatalError("Unresolved error \(error), \(error.userInfo)")
                    }
                }
            }
        }
        return container
    }()
}

extension Database {
    static func momRequest(identifier: String, sort: [(key: String, isAscending: Bool)]? = nil, params: [String: Any]? = nil) -> NSFetchRequest<NSFetchRequestResult>? {
        let coordinator = instance.persistentContainer.persistentStoreCoordinator
        var request = params != nil ? coordinator.managedObjectModel.fetchRequestFromTemplate(withName: identifier, substitutionVariables: params!) : coordinator.managedObjectModel.fetchRequestTemplate(forName: identifier)
        if let sort = sort {
            request = request?.copy() as? NSFetchRequest<NSFetchRequestResult>
            var sortDescriptors = [NSSortDescriptor]()
            for s in sort {
                sortDescriptors.append(NSSortDescriptor(key: s.key, ascending: s.isAscending))
            }
            request?.sortDescriptors = sortDescriptors
        }
        return request
    }
    
}

extension NSManagedObjectContext {
    func table<E: NSManagedObject>(_ type: E.Type) -> Database.Table<E> {
        Database.Table(in: self)
    }
    
    func subContext(_ context: Database.Context? = nil) -> NSManagedObjectContext {
        let context = NSManagedObjectContext(concurrencyType: (context?.thread.concurrencyType ?? concurrencyType))
        context.parent = self
        context.stalenessInterval = 0.0
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return context
    }
    
    func perform(_ block: @escaping (NSManagedObjectContext) -> Void) {
        perform { [weak self] in
            guard let selfStrong = self else { return }
            block(selfStrong)
        }
    }
}

extension NSManagedObject {
    static func create(by id: Any? = nil, key: String = "id", in moc: NSManagedObjectContext) -> Self {
        let request = NSFetchRequest<NSManagedObject>()
        request.entity = entity()
        if let id = id as? String {
            request.predicate = NSPredicate(format: "\(key) == \"\(id)\"")
        } else if let id = id as? Int  {
            request.predicate = NSPredicate(format: "\(key) == \(id)")
        }
        if request.predicate != nil,
           let exsis = (try? moc.fetch(request))?.first {
            return exsis as! Self
        }
        let result = self.init(context: moc)
        result.setValue(id, forKey: key)
        return result
    }
    
    func delete() {
        managedObjectContext?.delete(self)
    }
    
    func objectFromContext<E: NSManagedObject>(by e: E?) -> E? {
        e == nil ? nil : managedObjectContext?.object(with: e!.objectID) as? E
    }
    
    func unattended() -> Bool {
        !isUpdated && !isInserted
    }
}
