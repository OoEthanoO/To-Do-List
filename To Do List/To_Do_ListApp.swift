//
//  To_Do_ListApp.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import SwiftUI
import CoreData

@main
struct To_Do_ListApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    private func setDueDateForTasksWithoutDueDate() {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "haveDueDate == false")
        
        do {
            let tasksWithoutDueDate = try context.fetch(fetchRequest)
            for task in tasksWithoutDueDate {
                task.dueDate = Date()
            }
            try context.save()
        } catch {
            print("Error setting due date for tasks without due dates: \(error)")
        }
    }
    
    private func deleteTasksWithEmptyTitle() {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "title == %@", "")
        
        do {
            let tasksWithEmptyTitle = try context.fetch(fetchRequest)
            for task in tasksWithEmptyTitle {
                context.delete(task)
            }
            try context.save()
        } catch {
            print("Error deleting tasks with empty titles: \(error)")
        }
    }
}

