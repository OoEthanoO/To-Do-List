//
//  TaskDetails.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-25.
//

import SwiftUI

struct TaskDetails: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: Task
    
    var body: some View {
        Text("Edit Task")
            .font(.title.bold())
        
        List {
            HStack {
                TextField("Enter Task Name Here", text: $task.title)
                    .onChange(of: task.title) {
                        saveChanges() // Save changes when text field value changes
                    }
            }
            .padding()
            
            HStack {
                Text("Mark Complete")
                
                Spacer()
                
                Button {
                    task.isComplete.toggle()
                } label: {
                    Label("", systemImage: task.isComplete ? "checkmark.diamond.fill" : "checkmark.diamond")
                }
                .buttonStyle(PlainButtonStyle())
                .onChange(of: task.isComplete) {
                    saveChanges()
                }
            }
            .padding()
        }
    }
    
    private func saveChanges() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving changes: \(error.localizedDescription)")
        }
    }
}

#Preview {
    let result = PersistenceController(inMemory: true)
    let viewContext = result.container.viewContext
    let newTask = Task(context: viewContext)
    newTask.createdAt = Date()
    newTask.isComplete = false
    return TaskDetails(task: newTask)
}
