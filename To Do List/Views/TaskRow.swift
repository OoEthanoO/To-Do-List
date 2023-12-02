//
//  TaskRow.swift
//  To Do List
//
//  Created by Ethan Xu on 2023-11-29.
//

import SwiftUI

struct TaskRow: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var task: Task
    
    private let itemFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button {
                toggleComplete(task)
            } label: {
                Label("", systemImage: task.isComplete ? "checkmark.diamond.fill" : "checkmark.diamond")
                    .foregroundColor(task.isComplete ? .green : .blue)
                    .animation(.default, value: task.isComplete)
            }
            .buttonStyle(PlainButtonStyle())
            
            if task.priority != "None" {
                Label("", systemImage: "tag.fill")
                    .frame(width: 10)
                    .foregroundColor(priorityColor(task.priority))
                
            }
            
            VStack {
                HStack {
                    Text(task.title)
                        .strikethrough(task.isComplete)
                        .foregroundColor(task.isComplete ? .gray : priorityColor(task.priority))
                        .animation(.default)
                    
                    Spacer()
                }
                
                
                if task.haveDueDate && !task.isDeleted{
                    HStack {
                        Text(itemFormatter.string(from: task.dueDate))
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            Spacer()
                    }
                }
            }
            
            Button {
                deleteTask(task)
            } label: {
                Label("", systemImage: "trash.fill")
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    public func priorityColor(_ priority: String?) -> Color {
        switch priority {
        case "High":
            return .red
        case "Medium":
            return .yellow
        case "Low":
            return .green
        default:
            return .primary
        }
    }
    
    private func deleteTask(_ task: Task) {
        withAnimation {
            viewContext.delete(task)
            saveChanges()
        }
    }
    
    private func saveChanges() {
        withAnimation {
            do {
                try viewContext.save()
            } catch {
                _ = error as NSError
                print("Error saving changes: \(error.localizedDescription)")
            }
        }
    }
    
    private func toggleComplete(_ task: Task) {
        withAnimation {
            task.isComplete.toggle()
        }
    }
}

struct TaskRow_Previews: PreviewProvider {
    static var previews: some View {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        let newTask = Task(context: viewContext)
        newTask.title = "Sample Row"
        newTask.createdAt = Date()
        newTask.priority = "Low"
        newTask.isComplete = false
        newTask.dueDate = Date()
        newTask.haveDueDate = true
        
        return TaskRow(task: newTask)
            .environment(\.managedObjectContext, viewContext)
    }
}
