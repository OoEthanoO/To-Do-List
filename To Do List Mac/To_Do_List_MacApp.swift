//
//  To_Do_List_MacApp.swift
//  To Do List Mac
//
//  Created by Ethan Xu on 2023-11-29.
//

import SwiftUI

@main
struct To_Do_ListApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .onAppear {
                    AppDelegate().setDueDateForTasksWithoutDueDate()
                }
        }
    }
}

class AppDelegate {
    func setDueDateForTasksWithoutDueDate() {
        let context = PersistenceController.shared.container.viewContext
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "haveDueDate = false")
        
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
    
    func deleteTasksWithEmptyTitle() {
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
