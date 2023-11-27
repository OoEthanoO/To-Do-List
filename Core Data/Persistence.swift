//
//  Persistence.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newTask = Task(context: viewContext)
            newTask.createdAt = Date()
            newTask.title = "Sample Task"
            newTask.priority = "High"
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            print("Error saving changes in preview: \(error.localizedDescription)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "To_Do_List")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Error when loading persistent data: \(error.localizedDescription)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
